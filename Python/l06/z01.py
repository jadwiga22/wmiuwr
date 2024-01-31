# Jadwiga Swierczynska
# 06.11.2023

from collections import deque
import urllib.request
import re
import bs4

# returns html content of a website
def page_html_content(page):
    with urllib.request.urlopen(page) as f:
        text = f.read().decode('utf-8')
    return text

# returns human-readable text from html
def page_text_content(page_html):
    text = bs4.BeautifulSoup(page_html, 'html.parser').get_text(" ")
    return text

# returns list of all links on a page
def links(page):
    content = page_html_content(page)
    pattern = "((http)|(https))://([a-zA-Z]+.)*[a-zA-Z]+"
    # pattern = "((http))://([a-zA-Z]+.)*[a-zA-Z]+"
    return [url.group().replace(" ", "%20") for url in re.finditer(pattern, content)]

def crawl(start_page, distance, action):
    # distances from start_page (also helps in identifying visited websites)
    page_distances = {start_page : 0}

    # queue of pages to visit
    page_queue = deque()
    page_queue.append(start_page)

    while page_queue:
        cur_page = page_queue.popleft()

        try:
            yield (cur_page, action(page_html_content(cur_page)))

            if page_distances[cur_page] >= distance:
                continue

            for next in links(cur_page):
                if next not in page_distances:
                    page_distances[next] = page_distances[cur_page] + 1
                    page_queue.append(next)
        except urllib.error.URLError:
            pass
        except UnicodeDecodeError:
            pass
        except Exception as e:
            print(cur_page, e)
            raise e

def sentences_with(text, word):
    first_word_pattern = "(([A-Z][A-Za-z]*) )|([0-9]+ )"
    word_pattern = "([A-Za-z]+)|([0-9]+)"
    space_word_pattern = "( " + word_pattern + ")"
    word_space_pattern = "(" + word_pattern + " )"

    pattern = "(" + first_word_pattern + "(" + word_space_pattern + ")*)?" + word + space_word_pattern + "*\."

    return [url.group() for url in re.finditer(pattern, text)]

def pages_with_python(page):
    for url, wynik in crawl(page, 1, lambda html : sentences_with(page_text_content(html), "Python")):
        print(f"{url}: {wynik}")


def main():
    # for url, wynik in crawl("http://www.ii.uni.wroc.pl", 2, lambda tekst : "Python" in tekst):
    #     print(f"{url}: {wynik}")

    # pages_with_python("https://www.python.org/about/gettingstarted/")

    for url, wynik in crawl("https://www.geeksforgeeks.org/python-programming-language/", 1, lambda tekst : "Python" in tekst):
        print(f"{url}: {wynik}")

if __name__ == "__main__":
    main()