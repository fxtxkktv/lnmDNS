#coding: utf-8
import os,sys,json,re,logging,ConfigParser
from bottle import request,route,error,run,default_app
from bottle import template,static_file,redirect,abort
import bottle,hashlib

from MySQL import writeDb,readDb
from Functions import wrtlog,sendmail
from Login import checkLogin,checkAccess

@route('/changepasswd')
@checkLogin
def user():
    s = request.environ.get('beaker.session')
    return template('changepasswd',session=s,msg={},info={})

@route('/changepasswd',method="POST")
@checkLogin
def user():
    s = request.environ.get('beaker.session')
    username = s.get('username')
    oldpwd = request.forms.get("oldpwd")
    newpwd = request.forms.get("newpwd")
    newpwds = request.forms.get("newpwds")
    sql = " select password from user where username=%s "
    result = readDb(sql,(username,))
    #处理老密码
    m = hashlib.md5()
    m.update(oldpwd)
    password = m.hexdigest()
    if result[0].get('password') != password :
       msg = {'color':'red','message':u'旧密码验证失败，请重新输入'}
       return template('changepasswd',session=s,msg=msg,info={})
    if newpwd != newpwds :
       msg = {'color':'red','message':u'密码两次输入不一致，请重新输入'}
       return template('changepasswd',session=s,msg=msg,info={})
    #生成新密码md5
    n = hashlib.md5()
    n.update(newpwd)
    password = n.hexdigest()
    sql2 = " update user set password=%s where username=%s "
    result = writeDb(sql2,(password,username))
    if result == True :
       wrtlog('User','更改密码成功',username,s.get('clientip'))
       msg = {'color':'green','message':u'密码更新成功,后续请以新密码登录系统'}
       return template('changepasswd',session=s,msg=msg,info={})
    else:
       wrtlog('User','更改密码失败',username,s.get('clientip'))
       msg = {'color':'red','message':u'密码更新失败,请核对错误'}
       return template('changepasswd',session=s,msg=msg,info={})

@route('/administrator')
@checkAccess
def user():
    s = request.environ.get('beaker.session')
    return template('admin',session=s,msg={})

@route('/user')
@checkAccess
def user():
    s = request.environ.get('beaker.session')
    return template('user',session=s,msg={})

@route('/adduser')
@checkAccess
def adduser():
    s = request.environ.get('beaker.session')
    return template('adduser',session=s,info={})

@route('/adduser',method="POST")
@checkAccess
def adduser():
    s = request.environ.get('beaker.session')
    username = request.forms.get("username")
    password = request.forms.get("password")
    ustatus = request.forms.get("ustatus")
    comment = request.forms.get("comment")
    access = request.forms.get("access")
    #检查表单长度
    if len(username) < 4 or (len(password) < 8 or len(password) > 16) :
       message = "用户名或密码长度不符要求！"
       return '-2'
    else:
       #把密码进行md5加密码处理后再保存到数据库中
       m = hashlib.md5()
       m.update(password)
       md5password = m.hexdigest()

    #检测表单各项值，如果出现为空的表单，则返回提示
    if not (username and password ):
       message = "表单不允许为空！"
       return '-2'

    sql = """
            INSERT INTO
                user(username,password,ustatus,comment,access)
            VALUES(%s,%s,%s,%s,%s)
        """
    data = (username,md5password,ustatus,comment,access)
    result = writeDb(sql,data)
    if result:
       wrtlog('User','新增用户成功:%s' % username,s['username'],s.get('clientip'))
       return '0'
    else:
       wrtlog('User','新增用户失败:%s' % username,s['username'],s.get('clientip'))
       return '-1'

@route('/changeuser/<id>',method="POST")
@checkAccess
def do_changeuser(id):
    s = request.environ.get('beaker.session')
    username = request.forms.get("username")
    password = request.forms.get("password")
    ustatus = request.forms.get("ustatus")
    comment = request.forms.get("comment")
    access = request.forms.get("access")

    #把密码进行加密处理后再保存到数据库中
    if not password :
       sql = "select password from user where id = %s"
       md5password = readDb(sql,(id,))[0].get('password')
    else:
       m = hashlib.md5()
       m.update(password)
       md5password = m.hexdigest()

    #检查表单长度
    if len(username) < 4 or (len(password)>0 and (len(password) < 8 or len(password) > 16)) :
       msg = {'color':'red','message':'用户名或密码长度错误，提交失败!'}
       return '-2'

    if not username :
       msg = {'color':'red','message':'必填字段为空，提交失败!'}
       return '-2'

    sql = """
            UPDATE user SET
            username=%s,password=%s,ustatus=%s,comment=%s,access=%s
            WHERE id=%s
        """
    data = (username,md5password,ustatus,comment,access,id)
    result = writeDb(sql,data)
    if result == True:
       wrtlog('User','更新用户成功:%s' % username,s['username'],s.get('clientip'))
       msg = {'color':'green','message':'更新成功!'}
       return '0'
    else:
       wrtlog('User','更新用户失败:%s' % username,s['username'],s.get('clientip'))
       msg = {'color':'red','message':'更新失败!'}
       return '-1'
       #return template('user',session=s,msg=msg)

@route('/deluser',method="POST")
@checkAccess
def deluser():
    s = request.environ.get('beaker.session')
    id = request.forms.get('str').rstrip(',')
    if not id:
        return '-1'
    # 禁止删除ADMIN账户
    for i in id.split(','):
        if id == '1':
           return '-1'
        # MySQL多次删除ID,一次性删除异常
        sql = "delete from user where id in (%s) "
        result = writeDb(sql,(i,))
    if result:
       wrtlog('User','删除用户成功',s['username'],s.get('clientip'))
       return '0'
    else:
       wrtlog('User','删除用户失败',s['username'],s.get('clientip'))
       return '-1'

@route('/api/getadmin',method=['GET', 'POST'])
@checkAccess
def getuser():
    sql = """ SELECT id,username,ustatus,comment,
        date_format(adddate,'%%Y-%%m-%%d') as adddate 
        FROM user WHERE access = '1'
        order by username
    """
    userlist = readDb(sql,)
    return json.dumps(userlist)

@route('/clientdownload')
@checkLogin
def systeminfo():
    """客户端下载项"""
    s = request.environ.get('beaker.session')
    return template('filedown',session=s,message='',info={})

@route('/support')
@checkLogin
def policyconf():
    """问题反馈页"""
    s = request.environ.get('beaker.session')
    return template('support',session=s,msg={})

@route('/support',method="POST")
@checkLogin
def policyconf():
    """问题反馈页"""
    s = request.environ.get('beaker.session')
    subject = request.forms.get("subject")
    content = request.forms.get("content")
    if subject == '' and content == '':
       msg = {'color':'red','message':'主题或内容不能为空'}
       return template('support',session=s,msg=msg)
    result = sendmail(subject,content)
    if result == 1:
       msg = {'color':'red','message':'服务器连接失败，请检查配置!'}
       return template('support',session=s,msg=msg)
    elif result == 2:
       msg = {'color':'red','message':'用户名密码验证失败，请检查配置!'}
       return template('support',session=s,msg=msg)
    else:
       msg = {'color':'green','message':'邮件发送成功，请等待回复...'}
       return template('support',session=s,msg=msg)

if __name__ == '__main__' :
   sys.exit()
