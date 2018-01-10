import pandas as pd
import numpy as np
import builtins
from inspect import currentframe, getframeinfo
from IPython.display import HTML, display

def print(*args, **kwargs):
    cf = currentframe()
    builtins.print("#{}:".format(cf.f_back.f_lineno))
    builtins.print(*args, **kwargs)
    builtins.print('\n')

np.set_printoptions(precision=2)
pd.set_option('display.precision', 2)

def displayMovies(movies, movieIds, ratings=[]):
    html = ""
    for i, movieId in enumerate(movieIds):
        mov = movies[movies['movieId'] == movieId].iloc[0]
        html += """
            <div style="display:inline-block;min-width:150px;max-width:150px;vertical-align: top;">
                <img src="{}" width="120"><br/>
        """.format(mov.imgurl)
        if i < len(ratings):
            html += "<span>{:.4f}</span><br/>".format(ratings[i])
        html += "{}<br/>".format(mov.title)
        if mov.genres:
            ul = "<ul>"
            for genre in mov.genres.split('|'):
                ul += "<li>{}</li>".format(genre)
            ul += "</ul>"
            html += "{}<br/>".format(ul)
        html += "</div>"
    display(HTML(html))

