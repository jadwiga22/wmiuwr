# Jadwiga Swierczynska
# 11.10.2023


# checking if a text is a palindrom
def is_palindrom(text):
    translation = {
        " " : "",
        "," : "",
        "." : "",
        ":" : "",
        ";" : "",
        "-" : "",
        "?" : "",
        "!" : "",
        "\n" : ""
    }

    translation_ascii = {}
    for s in translation:
        translation_ascii[ord(s)] = translation[s]

    text = text.lower().translate(translation_ascii)
    return text == text[::-1]

def main():
    print(is_palindrom("Kobyła ma mały bok."))
    print(is_palindrom("Eine güldne, gute Tugend: Lüge nie!"))
    print(is_palindrom("Míč omočím."))
    print(is_palindrom("nonpalindrom"))
    print(is_palindrom(""))
    print(is_palindrom("a"))
    print(is_palindrom("ab"))

if __name__ == '__main__':
    main()