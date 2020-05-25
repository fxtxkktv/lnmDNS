%rebase base position='DNS全局配置'
<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">DNS全局配置</span>
                    <div class="widget-buttons">
                        <a href="#" data-toggle="maximize">
                            <i class="fa fa-expand"></i>
                        </a>
                        <a href="#" data-toggle="collapse">
                            <i class="fa fa-minus"></i>
                        </a>
                        <a href="#" data-toggle="dispose">
                            <i class="fa fa-times"></i>
                        </a>
                    </div>
                    
                </div><!--Widget Header-->
                <div style="padding:-10px 0px;" class="widget-body no-padding">
                <form action="" method="post">
		        %if msg.get('message'):
                    <span style="color:{{msg.get('color','')}};font-weight:bold;">&emsp;{{msg.get('message','')}}</span>
                %end
                <div class="modal-body">
                  <div class="input-group">
                   <span class="input-group-addon" style="width:137px">服务运行状态</span>
                   %if info.get('servstatus','') == 0 :
                    <input type="text" style="width:400px;color:green;font-weight:bold;" class="form-control" id="" name="record" aria-describedby="inputGroupSuccess4Status" value="正在运行" readonly>
                   %else :
                    <input type="text" style="width:400px;color:red;font-weight:bold;" class="form-control" id="" name="record" aria-describedby="inputGroupSuccess4Status" value="服务关闭" readonly>
                   %end
                  </div>
                </div>
		        <div class="modal-body">
                        <div class="input-group">
                          <span class="input-group-addon" style="width:137px">服务器域名&emsp;</span>
			              <input type="text" style="width:400px" class="form-control" id="" name="dns_domain" onkeyup="this.value=this.value.replace(/[^\w./]/g,'')" onafterpaste="this.value=this.value.replace(/[^\d./]/g,'')" placeholder="" aria-describedby="inputGroupSuccess4Status"
                           %if info.get('dns_domain',''): 
                                value="{{info.get('dns_domain','')}}"
                           %else :
                                value=""
                           %end 
			               required>
                       </div>
               </div>
		       <div class="modal-body">
                        <div class="input-group">
                          <span class="input-group-addon" style="width:137px">主DNS服务器&emsp;</span>
                          <input type="text" style="width:400px" class="form-control" id="" name="primary_dns" onkeyup="this.value=this.value.replace(/[^\w./]/g,'')" onafterpaste="this.value=this.value.replace(/[^\w./]/g,'')" placeholder="" aria-describedby="inputGroupSuccess4Status" 
                         %if info.get('primary_dns',''): 
                                value="{{info.get('primary_dns','')}}"
                          %else :
                                value=""
                          %end 
			              required>
                        </div>
               </div>
               <div class="modal-body">
                        <div class="input-group">
                          <span class="input-group-addon" style="width:137px">辅DNS服务器&emsp;</span>
                          <input type="text" style="width:400px" class="form-control" id="" name="second_dns" onkeyup="this.value=this.value.replace(/[^\w./]/g,'')" onafterpaste="this.value=this.value.replace(/[^\w./]/g,'')" placeholder="" aria-describedby="inputGroupSuccess4Status" 
                         %if info.get('second_dns',''): 
                                value="{{info.get('second_dns','')}}"
                          %else :
                                value=""
                          %end 
                          required>
                        </div>
               </div>
               <div class="modal-body">
                        <div class="input-group">
                          <span class="input-group-addon" style="width:137px">DNS转发列表&emsp;</span>
                          <input type="text" style="width:400px" class="form-control" id="" name="relay_dns" onkeyup="this.value=this.value.replace(/[^\d\.\,]/g,'')" onafterpaste="this.value=this.value.replace(/[^\w./]/g,'')" placeholder="" aria-describedby="inputGroupSuccess4Status" 
                         %if info.get('relay_dns',''): 
                                value="{{info.get('relay_dns','')}}"
                          %else :
                                value="8.8.8.8,8.8.4.4"
                          %end 
                          required>
                        </div>
               </div>
		       <div class="modal-body">
                        <div class="input-group">
                          <span class="input-group-addon" style="width:137px">TTL设置</span>
			              <input type="text" style="width:200px" class="form-control" id="" name="dns_ttl" onkeyup="value=value.replace(/[^\d\.\/]/ig,'')" placeholder="默认刷新时间" aria-describedby="inputGroupSuccess4Status" 
                          %if info.get('dns_ttl',''): 
                                value="{{info.get('dns_ttl','')}}"
                          %else :
                                value="3600"
                          %end 
                          required>
                          <input type="text" style="width:200px" class="form-control" id="" name="dns_min_ttl" onkeyup="value=value.replace(/[^\d\.\/]/ig,'')" placeholder="最小刷新时间" aria-describedby="inputGroupSuccess4Status" 
                          %if info.get('dns_min_ttl',''): 
                                value="{{info.get('dns_min_ttl','')}}"
                          %else :
                                value="60"
                          %end 
                          required>
                       </div>
               </div>
               <div class="modal-body">
                        <div class="input-group">
                          <span class="input-group-addon" style="width:137px">其他设置</span>
                          <input type="text" style="width:120px" class="form-control" id="" name="resp_person" onkeyup="value=value.replace(/[^\w\.\/]/ig,'')" placeholder="resp_person" aria-describedby="inputGroupSuccess4Status" 
                          %if info.get('resp_person',''): 
                                value="{{info.get('resp_person','')}}"
                          %else :
                                value=""
                          %end 
                          required>
                          <input type="text" style="width:70px" class="form-control" id="" name="refresh" onkeyup="value=value.replace(/[^\d\.\/]/ig,'')" placeholder="refresh" aria-describedby="inputGroupSuccess4Status" 
                          %if info.get('refresh',''): 
                                value="{{info.get('refresh','')}}"
                          %else :
                                value="3600"
                          %end 
                          required>
                          <input type="text" style="width:70px" class="form-control" id="" name="retry" onkeyup="value=value.replace(/[^\d\.\/]/ig,'')" placeholder="retry" aria-describedby="inputGroupSuccess4Status" 
                          %if info.get('retry',''): 
                                value="{{info.get('retry','')}}"
                          %else :
                                value="3600"
                          %end 
                          required>
                          <input type="text" style="width:70px" class="form-control" id="" name="expire" onkeyup="value=value.replace(/[^\d\.\/]/ig,'')" placeholder="expire" aria-describedby="inputGroupSuccess4Status" 
                          %if info.get('expire',''): 
                                value="{{info.get('expire','')}}"
                          %else :
                                value="86400"
                          %end 
                          required>
                          <input type="text" style="width:70px" class="form-control" id="" name="minimum" onkeyup="value=value.replace(/[^\d\.\/]/ig,'')" placeholder="minimum" aria-describedby="inputGroupSuccess4Status" 
                          %if info.get('minimum',''): 
                                value="{{info.get('minimum','')}}"
                          %else :
                                value="3600"
                          %end 
                          required>
                       </div>
               </div>
		       <div class="modal-body">
		          <div class="input-group">
                      <span class="input-group-addon"  style="width:137px" >宕机检测&emsp;</span>
                      <select style="width:200px" class="form-control" id="passiveenable" name="dns_dis_nn">
                                <option 
                                %if info.get('dns_dis_nn','') == 1:
                                        selected
                                %end 
                                value="1">开启
                                </option>
                                <option 
                                %if info.get('dns_dis_nn','') == 0:
                                        selected
                                %end 
                                        value="0">关闭
                                </option>
			          </select>
                  </div>
		       </div>
               <div class="modal-body">
                    <span class="input-group-addon" style="width:537px">域名指定DNS转发解析</span>
                    <textarea id="force_domain_dns" name="force_domain_dns" onkeyup="this.value=this.value.replace(/[^\w\d.\|\-\,\/\\\n]/g,'')" placeholder="lnmdns|223.5.5.5,223.6.6.6" style="width:537px;height:100px;resize:vertical;">{{info.get('force_domain_dns','')}}</textarea>
               </div>
		       </div>
                    <div class="modal-footer">
                        <button type="submit" style="float:left" class="btn btn-primary">保存</button>
                    </div>
                </div>
              </form>
            </div>
        </div>
    </div>
</div>
<script src="/assets/js/datetime/bootstrap-datepicker.js"></script> 
<script charset="utf-8" src="/assets/kindeditor/kindeditor.js"></script>
<script charset="utf-8" src="/assets/kindeditor/lang/zh_CN.js"></script>

<script language="JavaScript" type="text/javascript">
</script>
