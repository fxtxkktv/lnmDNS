%rebase base position='系统环境检测'
<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">系统检测</span>
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
                <div style="padding:-10px 0px;" class="widget-body no-padding col-lg-12 col-md-12 col-sm-12 col-xs-12">
                  <form action="" method="post">
		    <!--div class="modal-body">
		    	<span class="input-group-addon" style="width:500px">系统环境</span>
			<textarea id="sysenv" name="sysenv" placeholder="" style="width:500px;height:100px;" readonly>{{info.get('sysenv','')}}</textarea>
                    </div-->
		    <div class="modal-body">
			<span style="width:100%">组件环境</span>
			<textarea id="softenv" name="softenv" placeholder="" style="width:100%;height:600px;" readonly>{{info.get('software','')}}</textarea>
		    </div>    
                    <div class="modal-footer">
                        <button type="submit" style="float:left" class="btn btn-primary">重新检测</button>
			<a id="rego" style="float:left" class="btn btn-primary" href="#" onclick="javascript:history.back(-1);">返回</a>
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
