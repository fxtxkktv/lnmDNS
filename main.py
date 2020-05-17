#coding=utf-8
import os,sys,logging,time,datetime
import bottle
from bottle import run,default_app
from beaker.middleware import SessionMiddleware
from gevent import monkey
monkey.patch_all()

# set bottle upload file mem limit max size
bottle.BaseRequest.MEMFILE_MAX = 1024 * 1024 * 5

# get cur path and tools path
pro_path = os.path.split(os.path.realpath(__file__))[0]
sys.path.append('%s/libs' % pro_path)
sys.path.append('%s/tools' % pro_path)

# set global value
import Global as gl
gl._init()
gl.set_value('wkdir',pro_path)
gl.set_value('confdir','%s/config' % pro_path)
gl.set_value('plgdir','%s/plugins' % pro_path)
gl.set_value('tempdir','%s/template' % pro_path)
gl.set_value('assets','%s/assets' % pro_path)
gl.set_value('vwdir','%s/views' % pro_path)

import Login,User,Resources,System
from Functions import AppServer,runDaemonTask

# set log format
log_path = ('/'.join((pro_path,'logs')))
logging.basicConfig(level=logging.DEBUG,
        format = '%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
        datefmt = '%Y-%m-%d %H:%M:%S',
        filename = "%s/myapp_debug.log" % log_path,
        filemode = 'a')

# set session options
session_opts = {
    'session.type':'file',
    'session.cookei_expires':3600,
    'session.data_dir':'/tmp/sessions_ftp',
    'session.auto':True
    }

runListen = AppServer().getConfValue('ServConf','runListen')
runPort = AppServer().getConfValue('ServConf','runPort')
runSSL = AppServer().getConfValue('ServConf','runSSL')
runDebug = AppServer().getConfValue('ServConf','runDebug')

if __name__ == '__main__':
    # RUN INIT
    runDaemonTask()
    # Reload WEB
    app = default_app()
    app = SessionMiddleware(app, session_opts)
    if runSSL == 'False':
       run(app=app,host=runListen,port=int(runPort),debug=runDebug,server='gevent')
    elif runSSL == 'True':
       certfile='%s/certs/SSL/server.crt' % pro_path
       keyfile='%s/certs/SSL/server-key.pem' % pro_path
       run(app=app,host=runListen, port=int(runPort),server='gevent',debug=runDebug,certfile=certfile,keyfile=keyfile)
    else :
       print "Server Config Error..."
       sys.exit(1)
