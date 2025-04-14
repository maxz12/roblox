import aiohttp
import asyncio
import os
import time
import datetime
import random
import json
import sys


# Simple settings
class Settings:
    START_POSITION = 0  # Position to start in usernames.txt (0-based)
    CONCURRENT_REQUESTS = 8  # Lower number to avoid rate limits
    REQUEST_TIMEOUT = 8  # Seconds
    BATCH_DELAY = 0.5  # Seconds between batches
    RATE_LIMIT_PAUSE = 30  # Initial seconds to pause when rate limited
    MAX_RATE_LIMIT_PAUSE = 120  # Maximum seconds to pause (2 minutes)
    CHECK_INTERVAL = 10  # Check if rate limit is over every X seconds


# Statistics tracking
class Stats:
    def __init__(self):
        self.start_time = time.time()
        self.request_times = []
        self.available_usernames = []
        self.unavailable_usernames = []
        self.error_usernames = []
        self.checked_usernames = set()

    def add_result(self, username, status, time_taken):
        self.request_times.append(time_taken)
        self.checked_usernames.add(username)

        if status == "available":
            if username not in self.available_usernames:
                self.available_usernames.append(username)
        elif status == "unavailable":
            if username not in self.unavailable_usernames:
                self.unavailable_usernames.append(username)
        elif status == "error":
            if username not in self.error_usernames:
                self.error_usernames.append(username)

    def get_summary(self):
        total_time = time.time() - self.start_time

        if not self.request_times:
            return {
                "total_time": 0,
                "avg_time": 0,
                "fastest": 0,
                "slowest": 0,
                "requests_per_minute": 0,
                "total_checked": 0,
                "available": 0,
                "unavailable": 0,
                "errors": 0
            }

        avg_time = sum(self.request_times) / len(self.request_times)
        fastest = min(self.request_times) if self.request_times else 0
        slowest = max(self.request_times) if self.request_times else 0
        requests_per_minute = len(self.request_times) / (total_time / 60) if total_time > 0 else 0

        return {
            "total_time": total_time,
            "avg_time": avg_time,
            "fastest": fastest,
            "slowest": slowest,
            "requests_per_minute": requests_per_minute,
            "total_checked": len(self.checked_usernames),
            "available": len(self.available_usernames),
            "unavailable": len(self.unavailable_usernames),
            "errors": len(self.error_usernames)
        }


def should_stop():
    """Check if stop.txt exists."""
    return os.path.exists("stop.txt")


async def check_username(username, session):
    """Check if a username is available using Roblox API."""
    url = f"https://auth.roblox.com/v1/usernames/validate?request.username={username}&request.birthday=1990-01-01"

    start_time = time.time()

    try:
        async with session.get(url, timeout=Settings.REQUEST_TIMEOUT) as response:
            # Check for rate limiting
            if response.status == 429:
                return username, "rate_limited", time_taken, None

            response_text = await response.text()

            # Try to parse JSON
            try:
                data = json.loads(response_text)
                message = data.get("message", "")

                if data.get("code") == 0 and "valid" in message.lower():
                    status = "available"
                elif "already in use" in message.lower() or "not appropriate" in message.lower():
                    status = "unavailable"
                elif "too many requests" in message.lower():
                    status = "rate_limited"
                else:
                    status = "error"

            except:
                # If we can't parse JSON, it's likely an error page
                status = "error"

            time_taken = time.time() - start_time
            return username, status, time_taken, response_text

    except asyncio.TimeoutError:
        time_taken = time.time() - start_time
        return username, "error", time_taken, "Timeout"
    except Exception as e:
        time_taken = time.time() - start_time
        return username, "error", time_taken, str(e)


async def process_batch(usernames, total_usernames, start_idx, session, stats, retry_queue):
    """Process a batch of usernames."""
    tasks = []
    for username in usernames:
        if username not in stats.checked_usernames:
            tasks.append(check_username(username, session))

    if not tasks:
        return False

    results = await asyncio.gather(*tasks)

    rate_limited = False

    for i, result in enumerate(results):
        username, status, time_taken, response_text = result
        idx = start_idx + i

        if status == "rate_limited":
            rate_limited = True

            # Add unchecked usernames to retry queue
            for j in range(i, len(usernames)):
                retry_username = usernames[j]
                if retry_username not in stats.checked_usernames and retry_username not in retry_queue:
                    retry_queue.append(retry_username)

            # Stop processing this batch
            break

        if status == "available":
            symbol = "✅"
            availability = "Available"
        elif status == "unavailable":
            symbol = "❌"
            availability = "Taken"
        else:
            symbol = "⚠️"
            availability = "Error"
            if username not in retry_queue:
                retry_queue.append(username)

        percentage = (len(stats.checked_usernames) + 1) / total_usernames * 100

        # Display the result
        result_line = f"{symbol} [{idx + 1}/{total_usernames}] ({percentage:.4f}%) {username}: {availability} ({time_taken:.2f}s)"
        print(result_line)

        stats.add_result(username, status, time_taken)

    return rate_limited


def generate_results_file(usernames, stats):
    """Generate the results file."""
    summary = stats.get_summary()
    current_time = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M:%S")

    with open("results.txt", "w") as f:
        # Header section
        f.write(f"=== Roblox Username Check Results ===\n")
        f.write(f"Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): {current_time}\n")
        f.write(f"Current User's Login: maxz12ok\n")
        f.write(
            f"Progress: {summary['total_checked']}/{len(usernames)} usernames checked ({(summary['total_checked'] / len(usernames) * 100):.4f}% complete)\n\n")

        # Available usernames section
        f.write("=== ✅ AVAILABLE USERNAMES ===\n")
        for username in stats.available_usernames:
            f.write(f"{username}\n")
        if not stats.available_usernames:
            f.write("No available usernames found yet.\n")
        f.write("\n")

        # Unavailable usernames section
        f.write("=== ❌ UNAVAILABLE USERNAMES ===\n")
        for username in stats.unavailable_usernames:
            f.write(f"{username}\n")
        if not stats.unavailable_usernames:
            f.write("No unavailable usernames found yet.\n")
        f.write("\n")

        # Statistics section
        f.write("=== ⏱️ STATISTICS ===\n")
        f.write(f"Total time taken: {summary['total_time']:.2f} seconds\n")
        f.write(f"Average time per request: {summary['avg_time']:.2f} seconds\n")
        f.write(f"Fastest request: {summary['fastest']:.2f} seconds\n")
        f.write(f"Slowest request: {summary['slowest']:.2f} seconds\n")
        f.write(f"Requests per minute: {summary['requests_per_minute']:.2f}\n")


def save_progress(current_position, retry_queue):
    """Save the current progress."""
    with open("progress.json", "w") as f:
        json.dump({
            "position": current_position,
            "retry_queue": retry_queue
        }, f)


def load_progress():
    """Load progress from file if it exists."""
    if os.path.exists("progress.json"):
        try:
            with open("progress.json", "r") as f:
                data = json.load(f)
                return data.get("position", 0), data.get("retry_queue", [])
        except:
            print("Error loading progress file. Starting from the beginning.")
    return Settings.START_POSITION, []


async def wait_for_rate_limit(session):
    """Wait when rate limited."""
    wait_time = Settings.RATE_LIMIT_PAUSE
    start_time = time.time()

    print(f"⏸️ Rate limited! Pausing for {wait_time} seconds...")

    # Wait with periodic checks
    end_time = time.time() + wait_time
    while time.time() < end_time:
        remaining = int(end_time - time.time())
        elapsed = int(time.time() - start_time)

        # Check every X seconds if rate limit is over
        if elapsed > 0 and elapsed % Settings.CHECK_INTERVAL == 0:
            print("Testing if rate limit is over...")
            try:
                # Try a test request
                test_url = "https://auth.roblox.com/v1/usernames/validate?request.username=test12345&request.birthday=1990-01-01"
                async with session.get(test_url, timeout=5) as response:
                    if response.status != 429:
                        elapsed_time = int(time.time() - start_time)
                        print(f"🎉 Rate limit ended early after {elapsed_time} seconds!")
                        return
            except:
                pass  # If test fails, keep waiting

        # Update status every 5 seconds
        if remaining % 5 == 0:
            sys.stdout.write(f"\rWaiting: {remaining}s remaining ({elapsed}s elapsed)")
            sys.stdout.flush()

        # Check if we should stop
        if should_stop():
            print("\nStop file detected during pause.")
            return

        await asyncio.sleep(1)

    print(f"\nWait complete after {int(time.time() - start_time)} seconds. Resuming...")


async def main():
    # Load progress
    current_position, retry_queue = load_progress()

    # Override if START_POSITION is specified
    if Settings.START_POSITION > 0:
        current_position = Settings.START_POSITION

    # Read usernames
    try:
        with open("usernames.txt", "r") as f:
            usernames = [line.strip() for line in f if line.strip()]
    except:
        print("Error: usernames.txt file not found or couldn't be read.")
        return

    total_usernames = len(usernames)
    if not total_usernames:
        print("No usernames found in the file.")
        return

    print(f"Username Checker - Simple and Direct Version")
    print(f"===========================================")
    print(f"Total usernames: {total_usernames}")

    if retry_queue:
        print(f"Found {len(retry_queue)} usernames in retry queue from previous run")

    remaining = usernames[current_position:]
    if remaining:
        print(f"Starting from position {current_position} ({remaining[0]})")
    else:
        print(f"Starting from retry queue only")

    print(f"Using {Settings.CONCURRENT_REQUESTS} concurrent connections")

    # Initialize stats
    stats = Stats()

    # Create session
    timeout = aiohttp.ClientTimeout(total=Settings.REQUEST_TIMEOUT)
    connector = aiohttp.TCPConnector(ssl=False, limit=Settings.CONCURRENT_REQUESTS)

    async with aiohttp.ClientSession(
            headers={
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                'Accept': '*/*',
                'Accept-Language': 'en-US,en;q=0.9',
            },
            timeout=timeout,
            connector=connector
    ) as session:

        # First process retry queue
        while retry_queue:
            if should_stop():
                print("\nStop file detected. Saving progress...")
                save_progress(current_position, retry_queue)
                break

            batch = retry_queue[:Settings.CONCURRENT_REQUESTS]
            retry_queue = retry_queue[Settings.CONCURRENT_REQUESTS:]

            rate_limited = await process_batch(batch, total_usernames, 0, session, stats, retry_queue)

            # Save progress
            save_progress(current_position, retry_queue)
            generate_results_file(usernames, stats)

            # Handle rate limiting
            if rate_limited:
                await wait_for_rate_limit(session)
                if should_stop():
                    break
            else:
                await asyncio.sleep(Settings.BATCH_DELAY)

        # Then process remaining usernames
        while current_position < total_usernames:
            if should_stop():
                print("\nStop file detected. Saving progress...")
                save_progress(current_position, retry_queue)
                break

            batch = usernames[current_position:current_position + Settings.CONCURRENT_REQUESTS]
            old_position = current_position
            current_position += len(batch)

            rate_limited = await process_batch(batch, total_usernames, old_position, session, stats, retry_queue)

            # Save progress
            save_progress(current_position, retry_queue)
            generate_results_file(usernames, stats)

            # Handle rate limiting
            if rate_limited:
                current_position = old_position  # Go back to retry this batch
                await wait_for_rate_limit(session)
                if should_stop():
                    break
            else:
                await asyncio.sleep(Settings.BATCH_DELAY)

    # Final save
    save_progress(current_position, retry_queue)
    generate_results_file(usernames, stats)

    print(f"\n✅ Finished checking usernames.")

    if current_position >= total_usernames and not retry_queue:
        # Clean up if we're done
        try:
            os.remove("progress.json")
        except:
            pass


if __name__ == "__main__":
    if os.path.exists("stop.txt"):
        os.remove("stop.txt")

    print("To stop the process, create a file named 'stop.txt'")

    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nProgram interrupted by user. Progress has been saved.")
    except Exception as e:
        print(f"\nError: {e}")
        print("Program crashed, but progress has been saved and can be resumed.")