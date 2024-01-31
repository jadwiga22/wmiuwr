import requests
from urllib.request import urlopen

URL = "https://www.gutenberg.org/files/28044/28044-0.txt"

def downloadFile():
    r = requests.get(URL)

    with open('tmp.txt', 'wb') as ld:
        ld.write(r.content)
        ld.close()

def kompresja(text):
    if text == "":
        return ""
    
    curLetter = text[0]
    curOccs = 1

    compressed = []

    for i in range(1, len(text)):
        if text[i] == curLetter:
            curOccs += 1
        else:
            compressed.append((curLetter, curOccs))
            curLetter = text[i]
            curOccs = 1
    
    compressed.append((curLetter, curOccs))

    return compressed

def dekompresja(textList):
    decompressed = ""

    for a, occs in textList:
        decompressed += a * occs

    return decompressed


def main():
    downloadFile()

    with open('tmp.txt', 'r', encoding='utf-8') as f:
        data = f.read()

        print(kompresja(data))
        print(dekompresja(kompresja(data)) == data)

    print(kompresja('suuuper'))
    print(dekompresja(kompresja('suuuper')))

if __name__ == "__main__":
    main()
