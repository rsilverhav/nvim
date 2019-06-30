import base64
import json
import requests
import urllib.request
from os.path import expanduser

home = expanduser("~")
TOKENS_FILE = home + "/.tokens.json"

class Spotify():
    def __init__(self, vim):
        self.vim = vim

    def get_auth_string(self):
        encode_str = self.vim.eval("g:spotify_client_id") + ":" + self.vim.eval("g:spotify_client_secret")
        print("encode_str = " + encode_str)
        encode = base64.b64encode(encode_str.encode())
        return "Basic " + encode.decode()

    def codeToToken(self):
        authorization = self.get_auth_string()

        resp = requests.post( url="https://accounts.spotify.com/api/token",
                headers={"Authorization": authorization},
                data={"grant_type": "authorization_code",
                    "code": CODE,
                    "redirect_uri": self.vim.eval("g:spotify_redirect_url")})
        print(resp)
        print(resp.content)

    def get_tokens(self):
        f = open(TOKENS_FILE, "r")
        tokens = json.loads(f.read())
        f.close()
        return tokens

    def refresh_token(self):
        tokens = self.get_tokens()
        resp = requests.post(url="https://accounts.spotify.com/api/token",
                data={"grant_type": "refresh_token", "refresh_token": self.vim.eval("g:spotify_refresh_token")},
                headers={"Authorization": self.get_auth_string()})
        new_tokens_string = resp.content.decode("utf-8")
        print(resp)
        print(new_tokens_string)
        f = open(TOKENS_FILE, "w")
        f.write(new_tokens_string)
        f.close()

    def make_spotify_request(self, url, method, params, retry_on_fail):
        tokens = self.get_tokens()
        resp = None
        if method == "POST":
            resp = requests.post(url=url, headers={"Authorization": "Bearer " + tokens["access_token"]}, data=params)
        elif method == "GET":
            resp = requests.get(url=url, headers={"Authorization": "Bearer " + tokens["access_token"]}, data=params)
        elif method == "PUT":
            resp = requests.put(url=url, headers={"Authorization": "Bearer " + tokens["access_token"], "Content-Type": "application/json"}, data=params)
        if resp.status_code == 200:
            content = json.loads(resp.content)
            return content
        elif resp.status_code == 204:
            return True
        elif retry_on_fail:
            self.refresh_token()
            return self.make_spotify_request(url, method, params, False)


    def get_my_info(self):
        tokens = self.get_tokens()
        resp = self.make_spotify_request("https://api.spotify.com/v1/me", "GET", {}, True)
        print(resp)

    def get_playlists_data(self):
        tokens = self.get_tokens()
        resp = self.make_spotify_request("https://api.spotify.com/v1/me/playlists", "GET", {}, True)
        return resp["items"]

    def get_playlists_tracks_data(self, playlist_id):
        tokens = self.get_tokens()
        url = "https://api.spotify.com/v1/playlists/{}/tracks".format(playlist_id)
        songs_data = []
        while url != None:
            resp = self.make_spotify_request(url, "GET", {}, True)
            songs_data.extend(resp["items"])
            url = resp["next"]
        return songs_data

    def play_song(self, song_id):
        song_uri = "spotify:track:{}".format(song_id)
        data = { "uris": [song_uri] }
        resp = self.make_spotify_request("https://api.spotify.com/v1/me/player/play", "PUT", json.dumps(data), True)
        return resp
