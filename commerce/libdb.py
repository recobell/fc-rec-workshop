from IPython.display import Image, display, HTML

def displayImageUrls(urls):
    html = ""
    for url in urls:
        html += "<img src='" + url + "' width='170' style='display:inline-block'>"
    display(HTML(html))

def getImageUrls(rows, column_name = 'item_image'):
    images = [x[column_name] for x in rows]
    return images

def displayImageInRows(rows):
    displayImageUrls(getImageUrls(rows))
