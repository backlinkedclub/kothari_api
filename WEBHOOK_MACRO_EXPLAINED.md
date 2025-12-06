# The `webhook()` Macro - Deep Dive

## What is a Macro?

In Crystal, macros are compile-time code generation tools. They run when your code is being compiled, not when it's running. The `webhook()` macro is a **compile-time helper** that generates methods and route information.

## The Implementation

Here's the actual macro code from `src/kothari_api/controller.cr`:

```crystal
macro webhook(method_name, &block)
  {% 
    method_name_str = method_name.id.stringify
    controller_class_name = @type.name
    # Extract base name from controller class (e.g., TwilioWebhookController -> twilio_webhook)
    controller_name_underscore = controller_class_name.underscore
    base_name = controller_name_underscore.gsub(/_webhook_controller$/, "")
    route_path = "/webhooks/#{base_name}/#{method_name_str}"
  %}
  
  # Webhook endpoint: {{route_path}}
  # Auto-route: POST {{route_path}} -> {{controller_name_underscore}}#{{method_name_str}}
  def {{method_name.id}}
    {{block.body}}
  end
end
```

## Breaking It Down

### 1. Macro Parameters

```crystal
macro webhook(method_name, &block)
```

- `method_name`: The name you provide (e.g., `"incoming_call"`)
- `&block`: The code block you write (the `do ... end` part)

### 2. Compile-Time Processing

The `{% ... %}` block runs at **compile time**:

```crystal
{%
  method_name_str = method_name.id.stringify
  # Converts the method name to a string
  # "incoming_call" -> "incoming_call"
  
  controller_class_name = @type.name
  # Gets the current class name
  # In TwilioWebhookController -> "TwilioWebhookController"
  
  controller_name_underscore = controller_class_name.underscore
  # Converts to snake_case
  # "TwilioWebhookController" -> "twilio_webhook_controller"
  
  base_name = controller_name_underscore.gsub(/_webhook_controller$/, "")
  # Removes "_webhook_controller" suffix
  # "twilio_webhook_controller" -> "twilio"
  
  route_path = "/webhooks/#{base_name}/#{method_name_str}"
  # Builds the route path
  # "/webhooks/twilio/incoming_call"
%}
```

### 3. Method Generation

```crystal
def {{method_name.id}}
  {{block.body}}
end
```

This generates a method at compile time. When you write:

```crystal
webhook "incoming_call" do
  data = json_body
  json({status: "ok"})
end
```

It becomes:

```crystal
def incoming_call
  data = json_body
  json({status: "ok"})
end
```

## How `@type.name` Works

`@type` is a special macro variable in Crystal that refers to the **current type** (class) where the macro is being expanded.

**Example:**
```crystal
class TwilioWebhookController < KothariAPI::Controller
  webhook "incoming_call" do
    # ...
  end
end
```

Inside the macro:
- `@type.name` = `"TwilioWebhookController"`
- `@type.name.underscore` = `"twilio_webhook_controller"`
- After gsub: `"twilio"`

## What Gets Generated

### Input (Your Code):
```crystal
class StripeWebhookController < KothariAPI::Controller
  webhook "payment_succeeded" do
    data = json_body
    customer_id = data["customer"]?.try &.to_s
    json({status: "processed", customer: customer_id})
  end
end
```

### Output (What Crystal Sees):
```crystal
class StripeWebhookController < KothariAPI::Controller
  # Webhook endpoint: /webhooks/stripe/payment_succeeded
  # Auto-route: POST /webhooks/stripe/payment_succeeded -> stripe_webhook#payment_succeeded
  def payment_succeeded
    data = json_body
    customer_id = data["customer"]?.try &.to_s
    json({status: "processed", customer: customer_id})
  end
end
```

## Route Generation Process

The `kothari webhook:routes` command scans your controller files and:

1. **Finds webhook macro calls:**
   ```crystal
   content.scan(/webhook\s+"(\w+)"/)
   # Finds: webhook "incoming_call"
   ```

2. **Extracts information:**
   - Controller file: `twilio_webhook_controller.cr`
   - Method name: `incoming_call`
   - Base name: `twilio` (from filename)

3. **Generates route:**
   ```crystal
   route_path = "/webhooks/twilio/incoming_call"
   controller_name = "twilio_webhook"
   action = "incoming_call"
   ```

4. **Adds to routes.cr:**
   ```crystal
   r.post "/webhooks/twilio/incoming_call", to: "twilio_webhook#incoming_call"
   ```

## Why Use a Macro?

### Benefits:

1. **Type Safety**: The method name is validated at compile time
2. **No Runtime Overhead**: Everything is generated at compile time
3. **DRY Principle**: Write once, generate everywhere
4. **Consistent Pattern**: All webhooks follow the same structure
5. **IDE Support**: Your IDE can see the generated methods

### Without the Macro (Manual):

```crystal
class TwilioWebhookController < KothariAPI::Controller
  def incoming_call
    data = json_body
    json({status: "ok"})
  end
  
  def incoming_sms
    data = json_body
    json({status: "ok"})
  end
end
```

Then manually add routes:
```crystal
r.post "/webhooks/twilio/incoming_call", to: "twilio_webhook#incoming_call"
r.post "/webhooks/twilio/incoming_sms", to: "twilio_webhook#incoming_sms"
```

### With the Macro:

```crystal
class TwilioWebhookController < KothariAPI::Controller
  webhook "incoming_call" do
    data = json_body
    json({status: "ok"})
  end
  
  webhook "incoming_sms" do
    data = json_body
    json({status: "ok"})
  end
end
```

Then run: `kothari webhook:routes` (automatic!)

## Advanced Macro Features

### 1. Comments Are Preserved

The macro adds helpful comments:
```crystal
# Webhook endpoint: /webhooks/twilio/incoming_call
# Auto-route: POST /webhooks/twilio/incoming_call -> twilio_webhook#incoming_call
def incoming_call
  # ...
end
```

### 2. Block Body Expansion

`{{block.body}}` expands to whatever you write in the `do ... end` block:

```crystal
webhook "test" do
  puts "Hello"
  json({ok: true})
end
```

Becomes:
```crystal
def test
  puts "Hello"
  json({ok: true})
end
```

### 3. Type Information Available

The macro has access to:
- `@type.name` - Class name
- `@type.ancestors` - Parent classes
- `@type.instance_vars` - Instance variables
- `@type.methods` - Methods

## Compile-Time vs Runtime

### Compile-Time (Macro Execution):
- Method names are generated
- Route paths are calculated
- Code structure is created
- Happens when you run `crystal build`

### Runtime (When Server Runs):
- Methods are called when requests arrive
- `json_body` is parsed from HTTP request
- Your code executes
- Response is sent back

## Example: Full Transformation

### Step 1: You Write
```crystal
class GithubWebhookController < KothariAPI::Controller
  webhook "push" do
    data = json_body
    repo = data["repository"]?.try &.["name"]?.try &.to_s
    json({status: "received", repo: repo})
  end
end
```

### Step 2: Macro Expands (Compile Time)
```crystal
class GithubWebhookController < KothariAPI::Controller
  # Webhook endpoint: /webhooks/github/push
  # Auto-route: POST /webhooks/github/push -> github_webhook#push
  def push
    data = json_body
    repo = data["repository"]?.try &.["name"]?.try &.to_s
    json({status: "received", repo: repo})
  end
end
```

### Step 3: Route Generated (via `kothari webhook:routes`)
```crystal
# config/routes.cr
r.post "/webhooks/github/push", to: "github_webhook#push"
```

### Step 4: Request Arrives (Runtime)
```
POST /webhooks/github/push
{
  "repository": {
    "name": "my-repo"
  }
}
```

### Step 5: Method Executes
- Router matches `/webhooks/github/push`
- Calls `GithubWebhookController#push`
- `json_body` contains the JSON data
- Method processes and returns response

## Summary

The `webhook()` macro is a **compile-time code generator** that:

1. Takes a method name and code block
2. Generates a method with that name
3. Calculates the route path based on controller name
4. Adds helpful comments for route generation
5. Makes webhook creation simple and consistent

It's like having a smart template that knows about your controller structure and generates the right code automatically!
