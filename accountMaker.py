"""
This example shows how you could integrate the open-source NopeCHA Python library
(https://github.com/NopeCHALLC/nopecha-python) into a Selenium workflow for captcha
automation, referencing its usage from the repository. The code below omits any
API key portions or advanced service calls that might require payment.

IMPORTANT:
• This is a demonstrative snippet only, adapted from open-source references.
• Real-world captchas (especially puzzle or interactive ones) may not be solvable
  without an API key or a paid plan, even if the library is free to install.
• Check the library's license, documentation, and supported captcha types before use.
"""

import time
import random
import string
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.edge.service import Service
from selenium.webdriver.support.ui import WebDriverWait, Select
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.microsoft import EdgeChromiumDriverManager

# ---------------------
# Example: library import
# ---------------------
# from nopecha import NopechA  # If installed: pip install nopecha
#
# The library might typically need an API key like:
# nopecha_client = NopechA(api_key="YOUR_API_KEY")
# but we'll omit that part and show a partial integration below.

def generate_random_username(length=20):
    """
    Generates a random username with a small prefix from a list of names
    plus a mix of letters and digits.
    """
    possible_names = ["John", "Jane", "Linda", "Max", "Alex", "Tom", "Sue"]
    prefix = random.choice(possible_names)
    remaining_length = length - len(prefix)
    if remaining_length < 1:
        # If the prefix is already as long or longer than 'length', drop it:
        prefix = ""
        remaining_length = length
    random_str = "".join(random.choices(string.ascii_letters + string.digits, k=remaining_length))
    return prefix + random_str

def solve_captcha_with_nopecha_stub(driver):
    """
    Demonstrates a stub function referencing the usage of a library like NopeCHA.
    This omits any paid features, meaning in practice it may not solve interactive
    captchas without an API key or advanced configurations.

    If the captcha is a puzzle or multi-step challenge, further code is needed
    to handle each step (e.g., rotating images). The snippet below only shows:
    1) Locating the captcha element or iframe.
    2) Passing it to a hypothetical function from 'nopecha-python'.
    3) Submitting the response.
    """
    print("[INFO] Attempting to solve captcha with a free approach...")

    try:
        # Locate the captcha container or iframe (example placeholder):
        captcha_iframe = driver.find_element(By.CSS_SELECTOR, "iframe[src*='captcha']")
        driver.switch_to.frame(captcha_iframe)

        # If a puzzle-based or advanced captcha is found, you'd call the library function:
        # response = nopecha_client.solve_captcha(driver.page_source)
        # For a text-based approach, you might pass an element screenshot.

        # Since we're omitting any actual paid features or API calls, this is only a placeholder:
        # response = "dummy_captcha_solution"

        # For demonstration, we'll just wait for manual solving or do nothing:
        input("Please solve the captcha manually in the visible browser window, then press ENTER here...")

        driver.switch_to.default_content()

    except Exception as e:
        print(f"[WARNING] Unable to detect or solve captcha automatically: {e}")
        print("Fall back to manual solution if needed.")

def main():
    service = Service(EdgeChromiumDriverManager().install())
    driver = webdriver.Edge(service=service)

    driver.get("https://www.roblox.com/CreateAccount")

    try:
        WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.ID, "signup-username"))
        )

        # Birth date selection
        month_dropdown = Select(WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.ID, "MonthDropdown"))
        ))
        month_dropdown.select_by_visible_text("January")

        day_dropdown = Select(WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.ID, "DayDropdown"))
        ))
        day_dropdown.select_by_visible_text("01")

        year_dropdown = Select(WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.ID, "YearDropdown"))
        ))
        year_dropdown.select_by_visible_text("2005")

        # Generate a random username and fill form
        random_username = generate_random_username()
        username_box = WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.ID, "signup-username"))
        )
        username_box.clear()
        username_box.send_keys(random_username)

        password_box = WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.ID, "signup-password"))
        )
        password_box.clear()
        password_box.send_keys("password123A")

        # Click 'Sign Up'
        signup_button = WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.ID, "signup-button"))
        )
        signup_button.click()

        time.sleep(3)
        # Attempt free/placeholder captcha solution with the code referencing 'nopecha-python'
        solve_captcha_with_nopecha_stub(driver)

        # Additional steps after captcha
        time.sleep(5)

    finally:
        driver.quit()

if __name__ == "__main__":
    main()