#!/usr/bin/env python3
import requests
import os
import textwrap

cache_dir  = os.getenv("QUOTE_CACHE_DIR", os.path.expanduser("~/.cache/desktop-quote"))
QUOTE_FILE = os.path.join(cache_dir, "quote.txt")
os.makedirs(cache_dir, exist_ok=True)

def get_wisdom():
    try:
        response = requests.get("https://zenquotes.io/api/random", timeout=10)
        if response.status_code == 200:
            data = response.json()[0]
            wrapper = textwrap.TextWrapper(width=48)
            wrapped_quote = wrapper.fill(text=data['q'])
            output = f"{wrapped_quote}\n— {data['a']}"
            with open(QUOTE_FILE, "w") as f:
                f.write(output)
    except Exception:
        if not os.path.exists(QUOTE_FILE):
            with open(QUOTE_FILE, "w") as f:
                f.write("The obstacle is the way.\n— Marcus Aurelius")

if __name__ == "__main__":
    get_wisdom()
