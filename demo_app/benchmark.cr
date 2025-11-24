require "http/client"
require "json"

# Simple benchmark script to test KothariAPI performance
class Benchmark
  @base_url : String
  @concurrent : Int32
  @requests : Int32

  def initialize(@base_url = "http://127.0.0.1:3000", @concurrent = 10, @requests = 1000)
  end

  def run
    puts "
🚀 KothariAPI Performance Benchmark"
    puts "=" * 60
    puts "Concurrent connections: #{@concurrent}"
    puts "Total requests: #{@requests}"
    puts "=" * 60

    # Test 1: Simple GET request (home page)
    puts "
📊 Test 1: GET / (Simple JSON response)"
    test_get("/", "GET /")

    puts "
" + "=" * 60
    puts "✅ Benchmark complete!"
    puts "=" * 60
    puts "
💡 Tip: Add more endpoints to test by editing benchmark.cr"
  end

  private def test_get(path : String, label : String)
    times = [] of Float64
    errors = 0

    start = Time.monotonic
    
    @requests.times do |i|
      begin
        req_start = Time.monotonic
        response = HTTP::Client.get("#{@base_url}#{path}")
        req_end = Time.monotonic
        
        if response.status_code == 200
          times << (req_end - req_start).total_milliseconds
        else
          errors += 1
        end
      rescue
        errors += 1
      end
    end

    elapsed = (Time.monotonic - start).total_seconds
    print_results(label, times, elapsed, errors)
  end

  private def test_post(path : String, data : Hash, label : String)
    times = [] of Float64
    errors = 0

    start = Time.monotonic
    
    @requests.times do |i|
      begin
        req_start = Time.monotonic
        response = HTTP::Client.post("#{@base_url}#{path}",
          headers: HTTP::Headers{"Content-Type" => "application/json"},
          body: data.merge({"title" => "#{data["title"]} #{i}"}).to_json)
        req_end = Time.monotonic
        
        if response.status_code == 201 || response.status_code == 200
          times << (req_end - req_start).total_milliseconds
        else
          errors += 1
        end
      rescue
        errors += 1
      end
    end

    elapsed = (Time.monotonic - start).total_seconds
    print_results(label, times, elapsed, errors)
  end

  private def print_results(label : String, times : Array(Float64), elapsed : Float64, errors : Int32)
    return if times.empty?
    
    times.sort!
    avg = times.sum / times.size
    min = times.first
    max = times.last
    p50 = times[times.size // 2]
    p95 = times[(times.size * 0.95).to_i]
    p99 = times[(times.size * 0.99).to_i]
    rps = times.size / elapsed

    puts "  Label: #{label}"
    puts "  Requests: #{times.size} (#{errors} errors)"
    puts "  Duration: #{elapsed.round(2)}s"
    puts "  Requests/sec: #{rps.round(0)} req/s"
    puts "  Latency:"
    puts "    Min:    #{min.round(2)}ms"
    puts "    Avg:    #{avg.round(2)}ms"
    puts "    P50:    #{p50.round(2)}ms"
    puts "    P95:    #{p95.round(2)}ms"
    puts "    P99:    #{p99.round(2)}ms"
    puts "    Max:    #{max.round(2)}ms"
  end
end

# Run benchmark
benchmark = Benchmark.new(concurrent: 10, requests: 1000)
benchmark.run