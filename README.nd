# Truth Social Monitor

This script monitors Donald Trump's account on Truth Social for new posts, translates them into Japanese, and sends them to a Discord channel via a webhook.

## Features

- **Fetches New Posts**: Regularly checks the Truth Social profile of `@realDonaldTrump`.
- **Avoids Duplicates**: Uses a local cache to keep track of posts that have already been processed and sent.
- **Content Translation**: Translates post content from English to Japanese.
    - Uses the Gemini API for high-quality translations if an API key is provided.
    - Falls back to the free MyMemory API if the Gemini API is not configured or fails.
- **Discord Notifications**: Sends formatted messages to a specified Discord webhook.
- **Media Handling**:
    - For text posts, it shows the original and translated versions.
    - For image posts, it attaches the image directly to the Discord message (if under 8MB) or sends a link.
    - For video posts, it sends a link to the video.
- **Flexible Execution**: Can be run once or as a continuous daemon process.
- **Silent Mode**: Can be run with suppressed output for cron jobs or systemd services.

## Requirements

- Python 3
- `requests` library
- `python-dotenv` library
- A `curl` binary that can bypass Cloudflare's browser checks (e.g., `curl_chrome116`). The script is hardcoded to use `/usr/local/bin/curl_chrome116`.
  - [GitHub - lwthiker/curl-impersonate: curl-impersonate: A special build of curl that can impersonate Chrome & Firefox](https://github.com/lwthiker/curl-impersonate)

## Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/trump-monitor.git
    cd trump-monitor
    ```

2.  **Install Python dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

3.  **Install `curl_chrome116`:**

    [GitHub - lwthiker/curl-impersonate: curl-impersonate: A special build of curl that can impersonate Chrome & Firefox](https://github.com/lwthiker/curl-impersonate)  
  
4.  **Create the environment file:**
    Create a file named `.env` in the root of the project directory and add your configuration details.

    ```ini
    # .env file
    DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/your/webhook_url"
    GEMINI_API_KEY="your_gemini_api_key_optional"
    ```
    - `DISCORD_WEBHOOK_URL` (Required): The webhook URL for the Discord channel you want to send notifications to.
    - `GEMINI_API_KEY` (Optional): Your Google Gemini API key for translation. If omitted, the script will use a free, rate-limited translation service.

5.  **Create the translation prompt file:**
    Create a file named `prompt` in the root of the project directory. This file contains the instructions for the translation model. Example:

    ```text
    # prompt file
    Please translate the following English text into natural-sounding Japanese.
    ```

## Usage

Make sure the script `truth-social-monitor` is executable:
```bash
chmod +x truth-social-monitor
```

### Run Once
To run the script once to check for new posts and then exit:
```bash
./truth-social-monitor
```

### Run in Daemon Mode
To run the script continuously in the background, checking for new posts at a set interval. For example, to check every 5 minutes (300 seconds):
```bash
./truth-social-monitor -d 300
```

### Silent Mode
To suppress all logging output except for errors, use the `-s` or `--silent` flag. This is useful when running as a background service or cron job.
```bash
# Run once silently
./truth-social-monitor -s

# Run in daemon mode silently
./truth-social-monitor -d 300 -s
```

cronjob example:
```bash
5 * * * * /path/to/truth-social-monitor -s >> /dev/null 2>&1
```

### Command-line Arguments

- `-d SECONDS`, `--daemon SECONDS`: Enables daemon mode. The script will run continuously, with a check interval of `SECONDS`.
- `-s`, `--silent`: Enables silent mode, suppressing all standard output.

## How It Works

1.  **Fetch**: The script uses a `curl_chrome116` subprocess to fetch the latest statuses from the Truth Social API, bypassing browser checks.
2.  **Filter**: It filters for original posts (not replies or re-posts) from the target user (`@realDonaldTrump`).
3.  **Cache Check**: For each post, it generates a unique hash and checks if a corresponding file exists in the `./cache` directory. If it exists, the post is considered old and is skipped.
4.  **Process & Translate**: If a post is new:
    - The HTML is stripped from the content.
    - The content is sent to the `translate_with_gemini` function. If a `GEMINI_API_KEY` is present, it uses the Gemini API. Otherwise, it falls back to `translate_with_free_service` (MyMemory API).
5.  **Notify**: A message is constructed and sent to the configured Discord webhook. It handles text, images, and videos differently to provide the best notification format.
6.  **Save Cache**: After a post is successfully processed, its hash is saved to a file in the `./cache` directory to prevent reprocessing. The cache is automatically pruned to keep only the 30 most recent entries.

