# Webhook.update() Helper - Rewriting Webhook Files

## Overview

The `Webhook.update()` helper allows you to rewrite/update existing webhook files with new logic. This is perfect for dynamic webhook generation based on user actions.

## Use Case: Messaging Profile with Sequences

### Scenario

User creates a messaging profile and configures message sequences. Each time they update sequences, the webhook file gets rewritten with the new logic.

## Example Flow

### Step 1: User Creates Messaging Profile

```crystal
# app/controllers/messaging_profiles_controller.cr
class MessagingProfilesController < KothariAPI::Controller
  def create
    data = json_body
    profile = MessagingProfile.create(
      name: data["name"].to_s,
      business_id: data["business_id"].as_i?
    )
    
    # Create initial webhook
    webhook_action = "messaging_profile_#{profile.id}"
    webhook_url = Webhook(controller_name: "twilio", action_name: webhook_action)
    
    json_post({
      profile: profile,
      webhook_url: webhook_url
    })
  end
end
```

**Creates:** `app/webhooks/twilio/messaging_profile_1.cr` (with default logic)

### Step 2: User Updates Message Sequences

```crystal
# app/controllers/message_sequences_controller.cr
class MessageSequencesController < KothariAPI::Controller
  def update
    data = json_body
    sequence = MessageSequence.find(data["id"].as_i?)
    profile = sequence.messaging_profile
    
    # Update sequence in database
    sequence.update(data)
    
    # Rewrite webhook file with updated logic
    webhook_action = "messaging_profile_#{profile.id}"
    method_body = generate_webhook_logic(profile)
    
    Webhook.update(
      controller_name: "twilio",
      action_name: webhook_action,
      method_body: method_body
    )
    
    json_update(sequence)
  end
  
  private def generate_webhook_logic(profile)
    sequences = profile.message_sequences.order("position ASC")
    
    logic = <<-CRYSTAL
    data = json_body
    from = data["From"]?.try &.to_s
    body = data["Body"]?.try &.to_s
    
    # Find or create conversation
    conversation = Conversation.find_or_create_by(
      profile_id: #{profile.id},
      from_number: from
    )
    
    # Get current step in sequence
    current_step = conversation.current_step || 0
    
    # Process based on sequences
    case current_step
CRYSTAL
    
    sequences.each_with_index do |seq, index|
      logic += <<-CRYSTAL
    when #{index}
      # Sequence: #{seq.name}
      #{seq.condition} if body == "#{seq.trigger}"
        #{seq.action}
        conversation.update(current_step: #{index + 1})
      end
CRYSTAL
    end
    
    logic += <<-CRYSTAL
    end
    
    json({status: "processed", step: current_step})
CRYSTAL
    
    logic
  end
end
```

### Step 3: Webhook File Gets Rewritten

**Before (default):**
```crystal
def messaging_profile_1
  data = json_body
  json({status: "received", action: "messaging_profile_1"})
end
```

**After (with sequences):**
```crystal
def messaging_profile_1
  data = json_body
  from = data["From"]?.try &.to_s
  body = data["Body"]?.try &.to_s
  
  # Find or create conversation
  conversation = Conversation.find_or_create_by(
    profile_id: 1,
    from_number: from
  )
  
  # Get current step in sequence
  current_step = conversation.current_step || 0
  
  # Process based on sequences
  case current_step
  when 0
    # Sequence: Welcome Message
    if body == "hello"
      send_reply("Welcome! Type 'help' for options")
      conversation.update(current_step: 1)
    end
  when 1
    # Sequence: Help Menu
    if body == "help"
      send_reply("1. Products\n2. Support\n3. Contact")
      conversation.update(current_step: 2)
    end
  end
  
  json({status: "processed", step: current_step})
end
```

## Complete Example

### Initial State

```crystal
# User creates profile
POST /messaging_profiles
→ Webhook() creates: messaging_profile_1.cr (default logic)
```

### After User Adds Sequences

```crystal
# User adds sequence #1
POST /message_sequences
{
  "profile_id": 1,
  "name": "Welcome",
  "trigger": "hello",
  "action": "send_reply('Welcome!')"
}

→ Webhook.update() rewrites: messaging_profile_1.cr
→ File now contains sequence #1 logic
```

### After User Adds More Sequences

```crystal
# User adds sequence #2
POST /message_sequences
{
  "profile_id": 1,
  "name": "Help Menu",
  "trigger": "help",
  "action": "send_reply('Options: 1, 2, 3')"
}

→ Webhook.update() rewrites: messaging_profile_1.cr
→ File now contains sequence #1 AND #2 logic
```

## Benefits

1. **Dynamic Logic**: Webhook file reflects current user configuration
2. **Meta-Programming**: Generate webhook logic from database records
3. **Always Up-to-Date**: File is rewritten whenever user updates sequences
4. **Isolated**: Each profile has its own webhook file
5. **Flexible**: Can generate any logic based on user actions

## Usage

```crystal
# Rewrite webhook file with new logic
method_body = <<-CRYSTAL
  data = json_body
  # Your generated logic here
  json({status: "updated"})
CRYSTAL

Webhook.update(
  controller_name: "twilio",
  action_name: "messaging_profile_1",
  method_body: method_body
)
```

This allows the webhook file to be a "living document" that updates as users configure their messaging!
