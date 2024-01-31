# Jadwiga Swierczynska
# 13.11.2023

import urllib.request
import re
import bs4
import threading, queue
from threading import Lock

# time (in seconds) after the worker is killed
TIMEOUT = 2

# returns html content of a website
def page_html_content(page):
    with urllib.request.urlopen(page) as f:
        text = f.read().decode('utf-8')
    return text

# returns human-readable text from html
def page_text_content(page_html):
    text = bs4.BeautifulSoup(page_html, 'html.parser').get_text(" ")
    return text

# implementation of thread-worker
# shared queue   - queue of pages to visit
# lock           - lock for dictionary shared between threads
# action         - action to execute for each page
# page_distances - dictionary with distances for visited pages (shared between threads)
# distance       - max distance from start_page
def worker(shared_queue, lock, action, page_distances, distance):
    while True:
        try:
            # gets next task from queue
            # if worker needs to wait >= 2s,
            # it gets killed
            page = shared_queue.get(timeout=TIMEOUT)

            html = page_html_content(page)
            pattern = "((http)|(https))://([a-zA-Z]+.)*[a-zA-Z]+"
            links = [url.group().replace(" ", "%20") for url in re.finditer(pattern, html)]

            print(f"Page {page}: {action(html)}")

            # locking the dictionary
            with lock:
                if page_distances[page] >= distance:
                    shared_queue.task_done()
                    continue
            
            # inserting new links to queue and page_distances
            for next in links:
                # locking the dictionary
                with lock:
                    if next not in page_distances:
                        page_distances[next] = page_distances[page] + 1
                        shared_queue.put(next)
        except queue.Empty:
            # killing the worker
            break
        except urllib.error.URLError:
            pass
        except UnicodeDecodeError:
            pass
        except Exception as e:
            pass
        
        shared_queue.task_done()

def crawl(start_page, distance, action):
    page_distances = {start_page : 0}
    shared_queue = queue.Queue()
    lock = Lock()
    ths = [ threading.Thread(target=worker,args=(shared_queue, lock, action, page_distances, distance)) for _ in range(10) ]
    [ t.start() for t in ths ]

    shared_queue.put(start_page)


def sentences_with(text, word):
    first_word_pattern = "(([A-Z][A-Za-z]*) )|([0-9]+ )"
    word_pattern = "([A-Za-z]+)|([0-9]+)"
    space_word_pattern = "( " + word_pattern + ")"
    word_space_pattern = "(" + word_pattern + " )"

    pattern = "(" + first_word_pattern + "(" + word_space_pattern + ")*)?" + word + space_word_pattern + "*\."

    return [url.group() for url in re.finditer(pattern, text)]

def pages_with_python(page):
    crawl(page, 1, lambda html : sentences_with(page_text_content(html), "Python"))


def main():
    # crawl("http://www.ii.uni.wroc.pl", 2, lambda tekst : "Python" in tekst)

    pages_with_python("https://www.python.org/about/gettingstarted/")

    # crawl("https://www.geeksforgeeks.org/python-programming-language/", 1, lambda tekst : "Python" in tekst)

if __name__ == "__main__":
    main()