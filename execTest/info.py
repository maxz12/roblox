#!/usr/bin/env python3
"""
Simple Roblox Lua VM Tests - Generates basic test scripts without external dependencies
"""
import os
import time
from pathlib import Path


def create_test_directory():
    """Create test directory"""
    test_dir = Path("./roblox_lua_tests")
    test_dir.mkdir(exist_ok=True)
    print(f"Created test directory: {test_dir}")
    return test_dir


def create_debug_scripts(test_dir):
    """Create simple debug scripts that try to print VM information"""
    debug_dir = test_dir / "debug_info"
    debug_dir.mkdir(exist_ok=True)
    print(f"Creating debug information scripts in {debug_dir}")

    scripts = [
        {
            "name": "basic_print.lua",
            "description": "Basic print test",
            "code": """
-- Basic print test
print("Lua script executed successfully")
print("This should appear in the Roblox console if script injection worked")
warn("INJECTION SUCCESSFUL")
            """
        },
        {
            "name": "vm_info.lua",
            "description": "Try to print Lua VM info",
            "code": """
-- Try to print Lua VM info
local vm_info = {}

-- Basic Lua version
vm_info.version = _VERSION
print("Lua Version:", vm_info.version)

-- Check for common globals
local globals = {"game", "workspace", "script", "print", "warn", 
                 "getfenv", "setfenv", "debug", "os", "io"}

print("Available globals:")
for _, name in ipairs(globals) do
    local exists = _G[name] ~= nil
    print("  " .. name .. ": " .. tostring(exists))
end

-- Try to get environment info
pcall(function()
    if getfenv then
        print("Environment keys:")
        for k, _ in pairs(getfenv()) do
            print("  " .. k)
        end
    end
end)

-- Check loaded packages
pcall(function()
    if package and package.loaded then
        print("Loaded packages:")
        for name, _ in pairs(package.loaded) do
            print("  " .. name)
        end
    end
end)

warn("VM INFO EXTRACTION COMPLETED")
            """
        },
        {
            "name": "security_checks.lua",
            "description": "Test security features",
            "code": """
-- Test basic security features
local security_report = {}

-- Test function replacement
pcall(function()
    local old_print = print
    print = function(...) 
        old_print("REPLACED PRINT FUNCTION:", ...)
    end
    print("Test after replacement")
    security_report.function_replacement = "VULNERABLE"
end)

-- Test global environment access
pcall(function()
    local env_access = getfenv(0) ~= nil
    security_report.global_env_access = env_access
end)

-- Test debug library access
pcall(function()
    security_report.debug_access = debug ~= nil
    if debug then
        security_report.debug_functions = {}
        for k, v in pairs(debug) do
            table.insert(security_report.debug_functions, k)
        end
    end
end)

-- Print results
print("Security test results:")
for test, result in pairs(security_report) do
    if type(result) == "table" then
        print("  " .. test .. ": " .. table.concat(result, ", "))
    else
        print("  " .. test .. ": " .. tostring(result))
    end
end

warn("SECURITY TESTS COMPLETED")
            """
        }
    ]

    for script in scripts:
        file_path = debug_dir / script["name"]
        with open(file_path, 'w') as f:
            f.write(script["code"])
        print(f"  Created: {script['name']} - {script['description']}")

    return len(scripts)


def create_injection_tests(test_dir):
    """Create simple injection test scripts"""
    injection_dir = test_dir / "injection_tests"
    injection_dir.mkdir(exist_ok=True)
    print(f"Creating injection test scripts in {injection_dir}")

    scripts = [
        {
            "name": "string_escape.lua",
            "description": "String escape test",
            "code": """
-- String escape test
local test1 = "Regular string"
print(test1)

local test2 = "String with \"quotes\" inside"
print(test2)

local test3 = "String with \\" .. 
             " potential escape" .. 
             " attack"
print(test3)

local test4 = [[
Multi-line string
with "quotes" and \\backslashes
]]
print(test4)

local test5 = [[String]] .. " with " .. [[concatenation]]
print(test5)

warn("STRING ESCAPE TEST COMPLETED")
            """
        },
        {
            "name": "env_access.lua",
            "description": "Environment access test",
            "code": """
-- Environment access test

-- Try to get global env
pcall(function()
    local env = getfenv(0)
    if env then
        print("Got global environment!")
        print("Found keys:")
        local count = 0
        for k, _ in pairs(env) do
            print("  " .. k)
            count = count + 1
            if count > 10 then
                print("  ... and more")
                break
            end
        end
    end
end)

-- Try to set global value
pcall(function()
    _G.INJECTION_TEST = "Value set by injection"
    print("Set global value:", _G.INJECTION_TEST)
end)

-- Try to access game object
pcall(function()
    if game then
        print("Game object accessible")
        print("Players:", game:GetService("Players"))
    end
end)

warn("ENVIRONMENT ACCESS TEST COMPLETED")
            """
        },
        {
            "name": "sandbox_test.lua",
            "description": "Test sandbox restrictions",
            "code": """
-- Test sandbox restrictions

-- Try accessing restricted modules
local modules = {"io", "os", "debug", "package"}
for _, module_name in ipairs(modules) do
    local module = _G[module_name]
    print(module_name .. " module: " .. (module ~= nil and "ACCESSIBLE" or "BLOCKED"))

    if module then
        print("  Functions:")
        local count = 0
        for k, _ in pairs(module) do
            print("    " .. k)
            count = count + 1
            if count > 5 then
                print("    ... and more")
                break
            end
        end
    end
end

-- Try executing OS commands
pcall(function()
    if os and os.execute then
        print("Trying os.execute:")
        local result = os.execute("echo test")
        print("  Result:", result)
    end
end)

warn("SANDBOX TEST COMPLETED")
            """
        },
        {
            "name": "memory_test.lua",
            "description": "Test memory operations",
            "code": """
-- Test memory operations

-- Create a large string
pcall(function()
    print("Creating large string...")
    local large_string = string.rep("A", 1000000) -- 1MB string
    print("Large string created, length: " .. #large_string)
end)

-- Create many tables
pcall(function()
    print("Creating many tables...")
    local tables = {}
    for i = 1, 10000 do
        tables[i] = {value = i, data = "test"}
        if i % 1000 == 0 then
            print("  Created " .. i .. " tables")
        end
    end
    print("Tables created")
end)

-- Force garbage collection
pcall(function()
    print("Forcing garbage collection...")
    collectgarbage("collect")
    print("Garbage collection completed")
end)

warn("MEMORY TEST COMPLETED")
            """
        },
        {
            "name": "character_test.lua",
            "description": "Test special characters",
            "code": """
-- Test special characters

-- Test various character types
local tests = {
    {"ASCII", "Normal ASCII text"},
    {"Symbols", "!@#$%^&*()_+-=[]{}|;:,.<>/?`~"},
    {"Unicode", "こんにちは 你好 안녕하세요"},
    {"Emoji", "🔥💻🚀🦄🎮"},
    {"Control", string.char(0) .. string.char(1) .. string.char(13) .. string.char(10)},
    {"Mixed", "Text with \\0 null: " .. string.char(0) .. " and unicode: 🔥"}
}

for _, test in ipairs(tests) do
    local name, value = test[1], test[2]
    print("Testing " .. name .. " characters:")
    print("  Length: " .. #value)
    print("  Value: " .. value)
end

warn("CHARACTER TEST COMPLETED")
            """
        }
    ]

    for script in scripts:
        file_path = injection_dir / script["name"]
        with open(file_path, 'w') as f:
            f.write(script["code"])
        print(f"  Created: {script['name']} - {script['description']}")

    return len(scripts)


def create_instruction_file(test_dir):
    """Create a simple instruction file"""
    instruction_path = test_dir / "INSTRUCTIONS.txt"

    with open(instruction_path, 'w') as f:
        f.write("""SIMPLE ROBLOX LUA VM TESTS
=======================

These scripts are designed to test Roblox's Lua VM and find potential vulnerabilities.
No external dependencies required!

How to Use These Scripts
------------------------

1. BASIC USAGE:
   - Copy the contents of these scripts
   - Try to inject them into Roblox Player using various methods
   - Watch for successful execution (look for "INJECTION SUCCESSFUL" warnings)

2. EXECUTION INDICATORS:
   - All scripts use print() and warn() to show successful execution
   - If you see output from these functions, your injection worked!

3. TEST CATEGORIES:

   Debug Info Scripts:
   - basic_print.lua: Simple test to verify execution
   - vm_info.lua: Attempts to get information about the Lua VM
   - security_checks.lua: Tests basic security features

   Injection Test Scripts:
   - string_escape.lua: Tests string escape handling
   - env_access.lua: Tests environment access capabilities
   - sandbox_test.lua: Tests sandbox restrictions
   - memory_test.lua: Tests memory operations
   - character_test.lua: Tests special character handling

4. WHAT TO LOOK FOR:
   - Any script execution at all (indicates successful injection)
   - Access to restricted functions or modules
   - Ability to modify the environment
   - Unusual behavior or crashes

If you find any vulnerabilities, document exactly:
1. How you injected the script
2. What specific script or code revealed the vulnerability
3. What unexpected behavior occurred

Good luck with your bug bounty hunting!
""")

    print(f"Created instruction file: {instruction_path}")


def create_copy_helper(test_dir):
    """Create helper script to easily copy script contents to clipboard"""
    helper_path = test_dir / "copy_to_clipboard.py"

    with open(helper_path, 'w') as f:
        f.write("""#!/usr/bin/env python3
\"\"\"
Helper script to copy Lua script contents to clipboard
Requires: pip install pyperclip
\"\"\"
import os
import sys
from pathlib import Path

try:
    import pyperclip
except ImportError:
    print("Please install pyperclip: pip install pyperclip")
    sys.exit(1)

def list_scripts(directory):
    scripts = []
    for i, file in enumerate(sorted(Path(directory).glob("**/*.lua"))):
        scripts.append((i+1, file))
        print(f"{i+1}. {file}")
    return scripts

def main():
    script_dir = Path(__file__).parent

    print("Available scripts:")
    scripts = list_scripts(script_dir)

    if not scripts:
        print("No Lua scripts found!")
        return

    try:
        choice = int(input("\\nEnter script number to copy to clipboard: "))
        if 1 <= choice <= len(scripts):
            script_path = scripts[choice-1][1]
            with open(script_path, 'r') as f:
                content = f.read()

            pyperclip.copy(content)
            print(f"\\nCopied {script_path} to clipboard!")
            print(f"Content length: {len(content)} characters")
        else:
            print("Invalid selection")
    except ValueError:
        print("Please enter a number")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
""")

    print(f"Created clipboard helper: {helper_path}")


def main():
    print("\nSimple Roblox Lua VM Tests Generator")
    print("=================================\n")

    start_time = time.time()

    # Create test directory structure
    test_dir = create_test_directory()

    # Create test scripts
    debug_count = create_debug_scripts(test_dir)
    injection_count = create_injection_tests(test_dir)

    # Create instruction file
    create_instruction_file(test_dir)

    # Create helper script
    create_copy_helper(test_dir)

    # Print summary
    end_time = time.time()
    print("\nScript Generation Summary:")
    print(f"- Created {debug_count} debug information scripts")
    print(f"- Created {injection_count} injection test scripts")
    print(f"- Total: {debug_count + injection_count} scripts generated")
    print(f"- Location: {test_dir}")
    print(f"- Time taken: {end_time - start_time:.2f} seconds")

    print("\nNext Steps:")
    print("1. Browse to the test directory to see the generated scripts")
    print("2. Use the INSTRUCTIONS.txt file for guidance")
    print("3. Try running the copy_to_clipboard.py script to easily copy script contents")
    print("4. Attempt to inject these scripts into Roblox and observe the results")


if __name__ == "__main__":
    main()