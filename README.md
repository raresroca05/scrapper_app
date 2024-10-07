# Scraper Application

## Task 1: Basic Scraping with CSS Selectors

### Rails App Setup:

* Create a Rails app (rails new scraper_app --api -T).
* Add nokogiri, httparty, and rspec-rails gems.
* Set up RSpec for testing.
* Implement Basic Scraping Logic:

* Create a ScrapersController to handle GET requests to /data.
* Extract fields using basic CSS selectors using Nokogiri.

## Task 2: Scraping Meta Information

### Extend the Scraper to Support Meta Tags:

* Modify ScrapersController to support extracting meta tag information when the meta field is provided in the request.

## Task 3: Caching and Optimization

### Implement Caching:

* Use Rails.cache to cache webpage responses to avoid making duplicate requests.
* Cache by URL with a reasonable expiration time (e.g., 12 hours).

## Future Scalability and Parallelism Suggestions

### Background Jobs
- **Sidekiq Integration**: The application could benefit from offloading scraping tasks to background jobs. This would allow for processing larger numbers of URLs without blocking the main request thread.

### Parallel Requests
- **Concurrent Scraping**: By introducing tools such as `concurrent-ruby` or running multiple threads, we can scrape several pages at once, improving the overall speed of the scraper when dealing with multiple URLs.

### Caching Enhancements
- **Persistent Caching**: The current caching mechanism can be improved by introducing Redis, which can handle more sophisticated caching scenarios, such as caching based on URL parameters or varying expiration times.

### Rate Limiting
- **Throttling Requests**: To avoid being blocked by target websites, a rate limiter can be introduced, ensuring that requests are made at a controlled pace.

### Error Handling
- **Improved Error Handling**: Better handling of network timeouts, invalid URLs, and missing data should be implemented to ensure the application can handle a wide variety of cases gracefully.
