#coding=utf-8
import os,sys,json,re,time,datetime,logging,zipfile,platform
from bottle import request,route,template,static_file,abort,redirect

from MySQL import writeDb,readDb,readDb2
from Login import checkLogin,checkAccess
from Functions import AppServer,LoginCls,cmdhandle,Formatdata,netModule,servchk,writeDNSconf

import Global as gl

#支持中文配置读取
sys.setdefaultencoding('utf-8')

cmds=cmdhandle()
netmod=netModule()

@route('/systeminfo')
@route('/')
@checkAccess
def systeminfo():
    """系统信息项"""
    s = request.environ.get('beaker.session')
    info=dict()
    info['hostname'] = platform.node()
    info['kernel'] = platform.platform()
    info['systime'] = cmds.getdictrst('date +"%Y%m%d %H:%M:%S"').get('result')
    cmdRun='cat /proc/uptime|awk -F. \'{run_days=$1/86400;run_hour=($1%86400)/3600;run_minute=($1%3600)/60;run_second=$1%60;printf("%d天%d时%d分%d秒",run_days,run_hour,run_minute,run_second)}\''
    info['runtime'] = cmds.getdictrst(cmdRun).get('result')
    info['pyversion'] = platform.python_version()
    info['memsize'] = cmds.getdictrst('cat /proc/meminfo |grep \'MemTotal\' |awk -F: \'{printf ("%.0fM",$2/1024)}\'|sed \'s/^[ \t]*//g\'').get('result')
    info['cpumode'] = cmds.getdictrst('grep \'model name\' /proc/cpuinfo |uniq |awk -F : \'{print $2}\' |sed \'s/^[ \t]*//g\' |sed \'s/ \+/ /g\'').get('result')
    info['v4addr'] = 'Wan: '+netmod.NetIP()
    info['appversion'] = AppServer().getVersion()
    """管理日志"""
    sql = " SELECT id,objtext,objact,objhost,objtime FROM logrecord order by id DESC limit 7 "
    logdict = readDb(sql,)
    return template('systeminfo',session=s,info=info,logdict=logdict)

class DateEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime.datetime):
            return obj.strftime('%Y-%m-%d %H:%M:%S')
        elif isinstance(obj, datetime.date):
            return obj.strftime("%Y-%m-%d")
        else:
            return json.JSONEncoder.default(self, obj)

@route('/systeminfo',method="POST")
@checkAccess
def do_systeminfo():
    s = request.environ.get('beaker.session')
    sql = " select value from sysattr where attr='resData' "
    info = readDb(sql,)
    try:
        ninfo=json.loads(info[0].get('value'))
    except:
        return False
    visitDay = ninfo.get('visitDay')
    try:
        date = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()-(int(visitDay) * 86400)))
        sql = " select info,tim from sysinfo where tim > (%s) order by id"
        resultData = readDb2(sql,(date,))
        result = [True,resultData]
    except Exception as e:
        result = [False,str(e)]
    return json.dumps({'resultCode':0,'result':result},cls=DateEncoder)

@route('/resconfig')
@checkAccess
def servtools():
    """资源配置"""
    s = request.environ.get('beaker.session')
    sql = " select value from sysattr where attr='resData' and servattr='sys' "
    result = readDb(sql,)
    try:
        info = json.loads(result[0].get('value'))
    except:
        return(template('resconfig',session=s,msg={},info={}))
    return template('resconfig',session=s,msg={},info=info)

@route('/resconfig',method="POST")
@checkAccess
def do_servtools():
    s = request.environ.get('beaker.session')
    ResState = request.forms.get("ResState")
    ResSaveDay = request.forms.get("ResSaveDay")
    ResInv = request.forms.get("ResInv")
    visitDay = request.forms.get("visitDay")
    try:
       int(ResSaveDay)
       int(visitDay)
       int(ResInv)
    except:
       msg = {'color':'red','message':'配置保存失败,参数不符合要求'}
       return redirect('/resconfig')
    if int(ResSaveDay) < 1 or int(visitDay) < 1 or int(ResInv) < 60 :
       msg = {'color':'red','message':'配置保存失败,参数不符合要求'}
       return redirect('/resconfig')
    idata = dict()
    idata['ResState'] = ResState
    idata['ResSaveDay'] = ResSaveDay
    idata['ResInv'] = ResInv
    idata['visitDay'] = visitDay
    sql = " update sysattr set value=%s where attr='resData' "
    iidata=json.dumps(idata)
    result = writeDb(sql,(iidata,))
    if result == True :
       msg = {'color':'green','message':'配置保存成功'}
    else:
       msg = {'color':'red','message':'配置保存失败'}
    return(template('resconfig',msg=msg,session=s,info=idata))

@route('/applog')
@checkAccess
def applog():
    """服务工具"""
    s = request.environ.get('beaker.session')
    return template('applog',session=s,msg={},info={})

@route('/api/getapplog',method=['GET', 'POST'])
@checkAccess
def getapplog():
    sql = """ SELECT id,objtime,objname,objtext,objact,objhost FROM logrecord order by id desc """
    item_list = readDb(sql,)
    return json.dumps(item_list, cls=DateEncoder)

@route('/dnsservconf')
@checkAccess
def addservconf():
    """新增服务配置项"""
    s = request.environ.get('beaker.session')
    sql = "select dns_domain,primary_dns,second_dns,dns_ttl,dns_min_ttl,relay_dns,resp_person,retry,refresh,expire,minimum,dns_dis_nn from dns_conf "
    result = readDb(sql,)
    info=result[0]
    info['servstatus']=servchk('53')
    return template('dnsservconf',session=s,msg={},info=info)

@route('/dnsservconf',method="POST")
@checkAccess
def do_adddnsservconf():
    """新增服务配置项"""
    s = request.environ.get('beaker.session')
    dns_domain = request.forms.get("dns_domain").strip('.')
    primary_dns = request.forms.get("primary_dns").strip('.')
    second_dns = request.forms.get("second_dns").strip('.')
    dns_ttl = request.forms.get("dns_ttl")
    dns_min_ttl = request.forms.get("dns_min_ttl")
    relay_dns = request.forms.get("relay_dns")
    resp_person = request.forms.get("resp_person").strip('.')
    retry = request.forms.get("retry")
    refresh = request.forms.get("refresh")
    expire = request.forms.get("expire")
    minimum = request.forms.get("minimum")
    dns_dis_nn = request.forms.get("dns_dis_nn")
    for ips in relay_dns.split(',') :
        if netmod.checkip(ips) == False:
           msg = {'color':'red','message':u'转发地址填写不合法，保存失败'}
           sql = " select dns_domain,primary_dns,second_dns,dns_ttl,dns_min_ttl,relay_dns,resp_person,retry,refresh,expire,minimum,dns_dis_nn from dns_conf "
           result = readDb(sql,)
           info=result[0]
           info['servstatus']=servchk('53')
           return template('dnsservconf',session=s,msg=msg,info=info)
    if netmod.is_domain(dns_domain) == False or netmod.is_domain(primary_dns) == False or netmod.is_domain(second_dns) == False or netmod.is_domain(resp_person) == False :
       msg = {'color':'red','message':u'地址填写不合法，保存失败'}
       sql = " select dns_domain,primary_dns,second_dns,dns_ttl,dns_min_ttl,relay_dns,resp_person,retry,refresh,expire,minimum,dns_dis_nn from dns_conf "
       result = readDb(sql,)
       info=result[0]
       info['servstatus']=servchk('53')
       return template('dnsservconf',session=s,msg=msg,info=info)
    sql = " UPDATE dns_conf set dns_domain=%s,primary_dns=%s,second_dns=%s,dns_ttl=%s,dns_min_ttl=%s,relay_dns=%s,resp_person=%s,retry=%s,refresh=%s,expire=%s,minimum=%s,dns_dis_nn=%s "
    data = (Formatdata(dns_domain),Formatdata(primary_dns),Formatdata(second_dns),dns_ttl,dns_min_ttl,relay_dns,Formatdata(resp_person),retry,refresh,expire,minimum,dns_dis_nn)
    result = writeDb(sql,data)
    if result == True :
       writeDNSconf(action='uptconf')
       msg = {'color':'green','message':u'配置保存成功'}
       sql = " select dns_domain,primary_dns,second_dns,dns_ttl,dns_min_ttl,relay_dns,resp_person,retry,refresh,expire,minimum,dns_dis_nn from dns_conf " 
       result = readDb(sql,)
       info=result[0]
       time.sleep(1) #防止检测FTP服务状态时异常
       info['servstatus']=servchk('53')
       return template('dnsservconf',session=s,msg=msg,info=info)
    else :
       msg = {'color':'red','message':u'配置保存失败'}
       sql = " select dns_domain,primary_dns,second_dns,dns_ttl,dns_min_ttl,relay_dns,resp_person,retry,refresh,expire,minimum,dns_dis_nn from dns_conf "
       result = readDb(sql,)
       info=result[0]
       info['servstatus']=servchk('53')
       return template('dnsservconf',session=s,msg=msg,info=info)

@route('/showlog')
@checkAccess
def showservlog():
    """显示日志项"""
    s = request.environ.get('beaker.session')
    result = cmds.getdictrst('tail -300 %s/named/log/query.log|awk \'{$4="";print $0}\'' % gl.get_value('plgdir'))
    return template('showlog',session=s,msg={},info=result)

@route('/domainlist')
@checkAccess
def showservlog():
    """显示日志项"""
    s = request.environ.get('beaker.session')
    return template('domainlist',session=s,msg={})

@route('/adddomain',method="POST")
@checkAccess
def showservlog():
    """添加域名"""
    s = request.environ.get('beaker.session')
    domain = request.forms.get("domain")
    domaintype = request.forms.get("domaintype")
    comment = request.forms.get("comment")
    etime = time.strftime('%Y-%m-%d',time.localtime(time.time()))
    serial = time.strftime('%s',time.localtime(time.time()))
    if netmod.is_domain(domain) == False:
       msg = {'color':'red','message':u'域名格式错误，添加失败'}
       return '255'
    sql_1 = """ INSERT INTO dns_domain (domain,domaintype,comment,etime,status) VALUES (%s,%s,%s,%s,1)"""
    result = writeDb(sql_1,(domain,domaintype,comment,etime))
    if result == True:
       sql_x = """ select dns_domain,primary_dns,second_dns from dns_conf """
       result = readDb(sql_x,)
       sql_2 = """ INSERT INTO dns_records (zone,host,type,view,data,serial) VALUE (%s,'@','SOA','any',%s,%s) """
       sql_3 = """ INSERT INTO dns_records (zone,host,type,view,data,serial) VALUE (%s,'@','NS','any',%s,%s) """
       writeDb(sql_2,(domain,result[0].get('dns_domain'),serial))
       writeDb(sql_3,(domain,result[0].get('primary_dns'),serial))
       writeDb(sql_3,(domain,result[0].get('second_dns'),serial))
       msg = {'color':'green','message':u'添加成功'}
       return '0'
    else:
       msg = {'color':'red','message':u'添加失败'}
       return '255'

@route('/changedomain/<id>',method="POST")
@checkAccess
def changedomain(id):
    """添加域名"""
    s = request.environ.get('beaker.session')
    domain = request.forms.get("domain")
    domaintype = request.forms.get("domaintype")
    comment = request.forms.get("comment")
    if netmod.is_domain(domain) == False:
       msg = {'color':'red','message':u'域名格式错误，添加失败'}
       return '255'
    sql_1 = """ UPDATE dns_domain set domain=%s,domaintype=%s,comment=%s where id=%s"""
    result = writeDb(sql_1,(domain,domaintype,comment,id))
    if result == True:
       msg = {'color':'green','message':u'更新成功'}
       return '0'
    else:
       msg = {'color':'red','message':u'更新失败'}
       return '255'

@route('/chgstatus/<nodetype>/<id>')
@checkAccess
def do_chgstatus(nodetype,id):
    s = request.environ.get('beaker.session')
    surl = request.environ.get('HTTP_REFERER')
    sql_1 = """ update dns_domain set status=%s where id=%s """
    sql_2 = """ update dns_records set status=%s where id=%s """
    sql_3 = """ update dns_ipset set status=%s where id=%s """
    msg = {'color':'green','message':u'状态更新成功'}
    if nodetype == 'domaindisable':
       data_1=(0,id)
       writeDb(sql_1,data_1)
       return template('domainlist',session=s,msg=msg)
    elif nodetype == 'domainactive':
       data_1=(1,id)
       writeDb(sql_1,data_1)
       return template('domainlist',session=s,msg=msg)
    elif nodetype == 'recorddisable':
       data_2=(0,id)
       writeDb(sql_2,data_2)
       return redirect(surl)
       #return template('recordconf',session=s,msg=msg)
    elif nodetype == 'recordactive':
       data_2=(1,id)
       writeDb(sql_2,data_2)
       return redirect(surl)
       #return template('recordconf',session=s,msg=msg)
    elif nodetype == 'aidnsdisable':
       data_3=(0,id)
       writeDb(sql_3,data_3)
       return template('aidns',session=s,msg=msg)
    elif nodetype == 'aidnsactive':
       data_3=(1,id)
       writeDb(sql_3,data_3)
       return template('aidns',session=s,msg=msg)

@route('/deldomain/<domain>')
@checkAccess
def do_deldomain(domain):
    s = request.environ.get('beaker.session')
    sql_1 = """ delete from dns_domain where domain=%s """
    sql_2 = """ delete from dns_records where zone=%s """
    result = writeDb(sql_1,(domain,))
    if result == True:
       writeDb(sql_2,(domain,))
       msg = {'color':'green','message':u'删除成功'}
       return template('domainlist',session=s,msg=msg)
    else :
       msg = {'color':'red','message':u'删除失败'}
       return template('domainlist',session=s,msg=msg)

@route('/delrecord/<id>')
@checkAccess
def do_delrecord(id):
    s = request.environ.get('beaker.session')
    surl = request.environ.get('HTTP_REFERER')
    sql_1 = """ delete from dns_records where id=%s """
    result = writeDb(sql_1,(id,))
    if result == True:
       msg = {'color':'green','message':u'删除成功'}
       return redirect(surl)
       #return template('domainlist',session=s,msg=msg)
    else :
       msg = {'color':'red','message':u'删除失败'}
       return redirect(surl)
       #return template('domainlist',session=s,msg=msg)

@route('/delaidns/<id>')
@checkAccess
def do_delaidns(id):
    s = request.environ.get('beaker.session')
    sql = """ select count(*) as count from dns_records where view=(select setname from dns_ipset where id=%s) """
    resultx = readDb(sql,(id,))
    if resultx[0].get('count') > 0 :
       msg = {'color':'red','message':u'无法删除，该地址库已被关联使用'}
       return template('aidns',session=s,msg=msg)
    sql_1 = """ delete from dns_ipset where id=%s """
    result = writeDb(sql_1,(id,))
    if result == True:
       msg = {'color':'green','message':u'删除成功'}
       return template('aidns',session=s,msg=msg)
    else :
       msg = {'color':'red','message':u'删除失败'}
       return template('aidns',session=s,msg=msg)

@route('/recordconf/<id>')
@checkAccess
def showrecordlog(id):
    """解析记录项"""
    s = request.environ.get('beaker.session')
    sql = """ select setname,setdesc from dns_ipset where status='1' order by id """
    result = readDb(sql,)
    return template('recordconf',domainid=id,view_list=result,session=s,msg={})

@route('/addrecord',method="POST")
@checkAccess
def do_addrecord():
    s = request.environ.get('beaker.session')
    zone = request.forms.get("zone")
    host = request.forms.get("host")
    rtype = request.forms.get("rtype")
    view = request.forms.get("view")
    data = request.forms.get("data").strip('.')
    comment = request.forms.get("comment")
    serial = time.strftime('%s',time.localtime(time.time()))
    if rtype == 'MX' :
       mx_priority = request.forms.get("mx_priority")
    else :
       mx_priority = ''
    if rtype == 'MX' and netmod.is_domain(data) == False :
       msg = {'color':'red','message':'记录数据格式错误'}
       return '-1'
    if rtype == 'CNAME' and netmod.is_domain(data) == False :
       msg = {'color':'red','message':'记录数据格式错误'}
       return '-1'
    if rtype == 'A' and netmod.checkip(data) == False :
       msg = {'color':'red','message':'记录数据格式错误'}
       return '-1'
    if rtype == 'PTR' and netmod.is_domain(data) == False :
       msg = {'color':'red','message':'数据格式错误'}
       return '-1'
    #获取全局设置值
    sql = "insert into dns_records (zone,host,type,mx_priority,view,data,comment,serial) VALUE (%s,%s,%s,%s,%s,%s,%s,%s)"
    data = (zone,host,rtype,mx_priority,view,Formatdata(data),comment,serial)
    result = writeDb(sql,data)
    if result == True:
       return '0'
    else:
       return '-1'

@route('/editrecord/<id>',method="POST")
@checkAccess
def do_editrecord(id):
    s = request.environ.get('beaker.session')
    zone = request.forms.get("zone")
    host = request.forms.get("host")
    rtype = request.forms.get("rtype")
    view = request.forms.get("view")
    data = request.forms.get("data").strip('.')
    ttl = request.forms.get("ttl")
    comment = request.forms.get("comment")
    serial = time.strftime('%s',time.localtime(time.time()))
    if rtype == 'MX' :
       mx_priority = request.forms.get("mx_priority")
    else :
       mx_priority = ''
    if rtype == 'MX' and netmod.is_domain(data) == False :
       msg = {'color':'red','message':'记录数据格式错误'}
       return '-1'
    if rtype == 'CNAME' and netmod.is_domain(data) == False :
       msg = {'color':'red','message':'记录数据格式错误'}
       return '-1'
    if rtype == 'A' and netmod.checkip(data) == False :
       msg = {'color':'red','message':'记录数据格式错误'}
       return '-1'
    if rtype == 'PTR' and netmod.checkip(data) == False :
       msg = {'color':'red','message':'数据格式错误'}
       return '-1'
    sql = "update dns_records set zone=%s,host=%s,type=%s,mx_priority=%s,view=%s,data=%s,ttl=%s,comment=%s where id=%s"
    data = (zone,host,rtype,mx_priority,view,Formatdata(data),ttl,comment,id)
    result = writeDb(sql,data)
    if result == True:
       return '0'
    else:
       return '-1'

@route('/aidns')
@checkAccess
def getaidns():
    """自定义地址库"""
    s = request.environ.get('beaker.session')
    return template('aidns',session=s,msg={})

@route('/addaidns',method="POST")
@checkAccess
def add_aidns():
    """自定义地址库"""
    s = request.environ.get('beaker.session')
    setname = request.forms.get("setname")
    setdesc = request.forms.get("setdesc")
    setdata = request.forms.get("setdata")
    utime = time.strftime('%Y-%m-%d',time.localtime(time.time()))
    objtext = request.forms.get("setdata").replace('\r\n','\n').strip()
    objtext = '\n'.join(sorted(set(objtext.split('\n'))))
    for ipaddr in objtext.split('\n'):
        if netmod.checkips(ipaddr) == False :
           msg = {'color':'red','message':u'添加失败，地址不合法'}
           return '-1'
    sql_1 = """ INSERT INTO dns_ipset (setname,setdesc,setdata,utime,setfrom,status) VALUES (%s,%s,%s,%s,2,1)"""
    result = writeDb(sql_1,(setname,setdesc,setdata,utime))
    if result == True:
       writeDNSconf(action='uptconf')
       msg = {'color':'green','message':'新增成功'}
       return 0
       #return template('aidns',session=s,msg=msg)
    else:
       msg = {'color':'red','message':'新增失败'}
       return '-1'
       #return template('aidns',session=s,msg=msg)

@route('/changeaidns/<id>',method="POST")
@checkAccess
def add_aidns(id):
    """修改地址库"""
    s = request.environ.get('beaker.session')
    setname = request.forms.get("setname")
    setdesc = request.forms.get("setdesc")
    setdata = request.forms.get("setdata")
    utime = time.strftime('%Y-%m-%d',time.localtime(time.time()))
    objtext = request.forms.get("setdata").replace('\r\n','\n').strip()
    objtext = '\n'.join(sorted(set(objtext.split('\n'))))
    for ipaddr in objtext.split('\n'):
        if netmod.checkips(ipaddr) == False :
           msg = {'color':'red','message':u'添加失败，地址不合法'}
           return '-1'
    sql_1 = """ UPDATE dns_ipset SET setname=%s,setdesc=%s,setdata=%s,utime=%s where id=%s"""
    result = writeDb(sql_1,(setname,setdesc,setdata,utime,id))
    if result == True:
       msg = {'color':'green','message':'新增成功'}
       return 0
       #return template('aidns',session=s,msg=msg)
    else:
       msg = {'color':'red','message':'新增失败'}
       return '-1'
       #return template('aidns',session=s,msg=msg)

@route('/syscheck')
@checkAccess
def syscheck():
    s = request.environ.get('beaker.session')
    result = cmds.envCheck()
    return template('systemcheck',session=s,info=result)

@route('/syscheck',method="POST")
@checkAccess
def do_syscheck():
    s = request.environ.get('beaker.session')
    result = cmds.envCheck()
    return(template('systemcheck',session=s,info=result))

# 备份集管理
@route('/backupset')
@checkAccess
def syscheck():
    s = request.environ.get('beaker.session')
    return template('backupset',session=s,msg={})

@route('/uploadfile')
@checkAccess
def syscheck():
    s = request.environ.get('beaker.session')
    return template('uploadfile',session=s,msg={})

@route('/uploadfile', method='POST')
@checkAccess
def do_upload():
    s = request.environ.get('beaker.session')
    category = request.forms.get('category')
    upload = request.files.get('upload')
    name, ext = os.path.splitext(upload.filename)
    if ext not in ('.bkt','.jpgsss'):
        msg = {'color':'red','message':u'文件格式不被允许.请重新上传'}
        return template('backupset',session=s,msg=msg)
    try:
        upload.save('%s/backupset' % gl.get_value('plgdir'))
        msg = {'color':'green','message':u'文件上传成功'}
        return template('backupset',session=s,msg=msg)
    except:
        msg = {'color':'red','message':u'文件上传失败'}
        return template('backupset',session=s,msg=msg)

@route('/startbackupset')
@checkAccess
def delbackupset():
    s = request.environ.get('beaker.session')
    createtm = time.strftime('%Y%m%d%H%M%S',time.localtime(time.time()))
    from MySQL import db_name,db_user,db_pass,db_ip,db_port
    backupsetname='backupset_%s.bkt' % createtm
    cmd='mysqldump -u%s -p%s -h%s -P%s %s > %s/backupset/%s ' % (db_user,db_pass,db_ip,db_port,db_name,gl.get_value('plgdir'),backupsetname)
    x,y = cmds.gettuplerst(cmd)
    if x == 0:
       msg = {'color':'green','message':u'备份完成'}
    else :
       msg = {'color':'red','message':u'备份失败'}
    return template('backupset',session=s,msg=msg)

@route('/download/<vdir>/<filename:re:.*\.zip|.*\.bkt>')
def download(vdir,filename):
    if vdir == 'backupset':
       download_path = '%s/backupset' % gl.get_value('plgdir')
    return static_file(filename, root=download_path, download=filename)

@route('/restore/<filename>')
@checkAccess
def restore(filename):
    s = request.environ.get('beaker.session')
    if filename != "":
       db_name = AppServer().getConfValue('Databases','MysqlDB')
       db_user = AppServer().getConfValue('Databases','MysqlUser')
       db_pass = AppServer().getConfValue('Databases','MysqlPass')
       db_ip = AppServer().getConfValue('Databases','MysqlHost')
       db_port = AppServer().getConfValue('Databases','MysqlPort')
       x,y=cmds.gettuplerst('mysql -h%s -P%s -u%s -p%s %s < %s/backupset/%s' % (db_ip,db_port,db_user,db_pass,db_name,gl.get_value('plgdir'),filename))
       if x == 0:
          msg = {'color':'green','message':u'备份集恢复成功,请重启服务以重新加载数据.'}
       else:
          msg = {'color':'red','message':u'备份集恢复失败'}
    else:
       msg = {'color':'red','message':u'备份集恢复失败'}
    return template('backupset',session=s,msg=msg)


@route('/delbackupset/<filename>')
@checkAccess
def delbackupset(filename):
    s = request.environ.get('beaker.session')
    if filename != "":
       x,y=cmds.gettuplerst('rm -rf %s/backupset/%s' % (gl.get_value('plgdir'),filename))
       if x == 0:
          msg = {'color':'green','message':u'备份集删除成功'}
       else:
          msg = {'color':'red','message':u'备份集删除失败'}
    return template('backupset',session=s,msg=msg)

@route('/api/getbackupsetinfo',method=['GET', 'POST'])
@checkAccess
def getbackupsetinfo():
    info=[]
    status,result=cmds.gettuplerst('find %s/backupset -name \'*.bkt\' -exec basename {} \;' % gl.get_value('plgdir'))
    for i in result.split('\n'):
        if str(i) != "":
           infos={}
           infos['filename']=str(i)
           infos['filesize']=os.path.getsize('%s/backupset/%s' % (gl.get_value('plgdir'),i))
           cctime=os.path.getctime('%s/backupset/%s' % (gl.get_value('plgdir'),i))
           infos['filetime']=time.strftime('%Y%m%d%H%M%S',time.localtime(cctime))
           info.append(infos)
    return json.dumps(info)

@route('/api/getdomainlist',method=['GET', 'POST'])
@checkAccess
def getdomaininfo():
    sql = """ SELECT id,domain,domaintype,comment,etime,status from dns_domain order by domain """
    domainlist = readDb(sql,)
    return json.dumps(domainlist, cls=DateEncoder)

@route('/api/getrecordlist/<id>',method=['GET', 'POST'])
@checkAccess
def getrecordlist(id):
    sql = """ SELECT E.id,E.host,E.type,E.data,E.ttl,E.view,F.setdesc,E.mx_priority,E.serial,E.autoupdate,E.comment,E.status from dns_records E LEFT OUTER JOIN dns_ipset F on E.view=F.setname where E.type!="SOA" and E.zone=%s"""
    recordlist = readDb(sql,(id,))
    return json.dumps(recordlist, cls=DateEncoder)

@route('/api/getaidnslist',method=['GET', 'POST'])
@checkAccess
def getaidnsinfo():
    sql = """ SELECT id,setname,setdesc,left(setdata,100) as setdt,setdata,utime,setfrom,status from dns_ipset where setfrom!='0' order by id """
    aidnslist = readDb(sql,)
    return json.dumps(aidnslist, cls=DateEncoder)

if __name__ == '__main__' :
   sys.exit()
