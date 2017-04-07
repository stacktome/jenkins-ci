import json
import logging
import tornado.ioloop
import tornado.web
from tornado.options import options, parse_command_line
import requests

def init_build(token, build_name):
    # token = "P7wmhh0ZiQ4HQKSYGwqzuaM9R4S9lNktXCFxx0SJmk"
    url = "http://jenkins.fuzzylabsresearch.com/buildByToken/buildWithParameters?job={0}&token={1}&BRANCH=master&".format(build_name, token)
    logging.debug("triggering build: {0}".format(url))
    requests.get(url)

class MainHandler(tornado.web.RequestHandler):
    def post(self):
        logging.debug("event received: {0}".format(repr(self.request.body)))
        token = self.get_argument("token")
        build_name = self.get_argument("build")
        payload = json.loads(self.request.body)
        pr = payload["pull_request"]
        if payload["action"] == "closed" and pr["merged"] and pr["base"]["ref"] == "master":
            logging.debug("PR merge in master detected")
            init_build(token, build_name)
            # if pr["base"]["repo"]["name"] == "clickstream-pipeline":
            #     init_build("BigQuerySinkFull")
            # if pr["base"]["repo"]["name"] == "recommendation-service":
            #     init_build("RecServiceFull")


        self.write("")
        self.finish()

def make_app():
    return tornado.web.Application([
        (r"/", MainHandler),
    ])

if __name__ == "__main__":
    options.logging = 'debug'
    parse_command_line()
    
    logging.debug("start")
    
    app = make_app()
    app.listen(8000)
    tornado.ioloop.IOLoop.current().start()