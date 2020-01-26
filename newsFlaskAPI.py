from flask import Flask, request, make_response, jsonify
import requests, json, pycountry

def country_to_code(name):
    x = pycountry.countries.get(name=name.title()   )
    return x.alpha_2

app = Flask(__name__)

@app.route("/filter")
def filter():
    apikey = "apikey=" #ADD YOUR API KEY"
    base_url = """https://newsapi.org/v2/top-headlines"""
    country = request.args.get("country")
    category = request.args.get("category")
    modified = False
    if (country != None):
        modified = True
        base_url = base_url + "?country=" + country
    if (category != None):
        if (modified):
            base_url = base_url + "&category=" + category
        else:
            base_url = base_url + "?category=" + category

    base_url = base_url + "&" + apikey

    return requests.get(base_url).json()

@app.route("/")
def home():
    apikey = "apikey=5bd98ac493484761a581e303619106f4"


if __name__ == "__main__":
    app.run(debug=True, port=5000)
