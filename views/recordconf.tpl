%rebase base position='解析管理',managetopli="active open",adduser="active"

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">解析管理</span>
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
                    <div class="tickets-container">
                        <div class="table-toolbar" style="float:left">
                            <a id="addrecord" href="javascript:void(0);" class="btn  btn-primary ">
                                <i class="btn-label fa fa-plus"></i>添加记录
                            </a>
                            <a id="editrecord" href="javascript:void(0);" class="btn btn-warning shiny">
                                <i class="btn-label fa fa-cog"></i>修改记录
                            </a>
                            %if msg.get('message'):
                      		 <span style="color:{{msg.get('color','')}};font-weight:bold;">&emsp;{{msg.get('message','')}}</span>
                    	    %end
                        </div>
                       <table id="myLoadTable" class="table table-bordered table-hover"></table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="myModal" tabindex="-1" role="dialog"  aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog" >
      <div class="modal-content" id="contentDiv">
         <div class="widget-header bordered-bottom bordered-blue ">
           <i class="widget-icon fa fa-pencil themeprimary"></i>
           <span class="widget-caption themeprimary" id="modalTitle">添加记录</span>
         </div>

         <div class="modal-body">
            <div>
            <form id="modalForm">
                <div class="form-group">
                  <label class="control-label" for="inputSuccess1">主机记录：</label>
                  <input type="text" class="form-control" onkeyup="value=value.replace(/[^\w\.\@]/ig,'')" id="host" name="host" placeholder="" required>
                </div>
                <div class="form-group">
                  <label class="control-label" for="inputSuccess1">记录类型：</label>
                  <select id="rtype" style="width:100%;" name="rtype">
                    <option value='A'>A</option>
                    <option value='CNAME'>CNAME</option>
                    <option value='MX'>MX</option>
                    <option value='TXT'>TXT</option>
                    <option value='PTR'>PTR</option>
                    <option value='NS'>NS</option>
                 </select>
               </div>
               <div class="form-group" id="mx_push">
                  <label class="control-label" for="inputSuccess1">优先级：</label>
                  <input type="text" class="form-control" onkeyup="value=value.replace(/[^\d]/ig,'')" id="mx_priority" name="mx_priority" placeholder="" required>
                </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">解析线路：</label>
                  <select id="view" style="width:100%;" name="view">
                    %for view in view_list:
                      <option value='{{view.get('setname','')}}'>{{view.get('setdesc','')}}</option>
                    %end
                 </select>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">记录值：</label>
                  <input type="text" class="form-control" onkeyup="value=value.replace(/[^\w\.]/ig,'')" id="data" name="data" placeholder="" required>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">TTL：</label>
                  <input type="text" class="form-control" onkeyup="value=value.replace(/[^\d]/ig,'')" id="ttl" name="ttl" value="3600" required>
               </div>
               <div class="form-group" id="a_push">
                  <label class="control-label" for="inputSuccess1">DDNS自动更新：</label>
                  <select id="autoupdate" style="width:100%;" name="autoupdate">
                    <option value='0'>关闭</option>
                    <option value='1'>开启</option>
                 </select>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">备注信息：</label>
                  <textarea id="comment" name="comment" style="height:30px;width:100%;" ></textarea>
              </div>
              <div class="form-group">
                  <input type="hidden" id="hidInput" value="">
                  <button type="button" id="subBtn" class="btn btn-primary  btn-sm">提交</button>
                  <button type="button" class="btn btn-warning btn-sm" data-dismiss="modal">关闭</button>
              </div>
            </form>
            </div>
         </div>
      </div>
   </div>
</div>
<script type="text/javascript">
$(function(){
    /* **表格数据 */
    var editId;        //定义全局操作数据变量
    var isEdit;
    $('#myLoadTable').bootstrapTable({
          method: 'post',
          url: '/api/getrecordlist/{{domainid}}',
          contentType: "application/json",
          datatype: "json",
          cache: false,
          checkboxHeader: true,
          striped: true,
          pagination: true,
          pageSize: 20,
          pageList: [10,20,50],
          search: true,
          showColumns: true,
          showRefresh: true,
          minimumCountColumns: 2,
          clickToSelect: true,
          smartDisplay: true,
          sortOrder: 'asc',
          sortName: 'id',
          columns: [{
              field: 'bianhao',
              title: 'checkbox',      
              checkbox: true,
          },{ 
              field: 'xid',
              title: '编号',
              align: 'center',
              valign: 'middle',
              width:25,
              formatter:function(value,row,index){
                return index+1;
              }
          },{
              field: 'host',
              title: '主机名',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'type',
              title: '记录类型',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'setdesc',
              title: '解析线路',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'data',
              title: '数据',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'ttl',
              title: 'TTL',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'comment',
              title: '备注',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'status',
              title: '状态',
              align: 'center',
              valign: 'middle',
              sortable: false,
              width:25,
              formatter: function(value,row,index){
                if( value == '1' ){
                        return '<img  src="/assets/img/run_1.gif" class="img-rounded" >';
                }else{  return '<img  src="/assets/img/run_0.gif" class="img-rounded" >';
                }
            }
          },{
              field: '',
              title: '操作',
              align: 'center',
              valign: 'middle',
              width:220,
              formatter:getinfo
          }]
    });

    //定义列操作
    function getinfo(value,row,index){
        eval('rowobj='+JSON.stringify(row));
        //定义显示启用停用按钮，只有管理员或自己编辑的任务才有权操作
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            if(rowobj['status'] == '1'){
               var style_action = '<a href="/chgstatus/recorddisable/'+rowobj['id']+'" class="btn-sm btn-success" >';
            }else{
               var style_action = '<a href="/chgstatus/recordactive/'+rowobj['id']+'" class="btn-sm btn-danger active" >';
            }
        }else{
            var style_action = '<a class="btn-sm btn-info" disabled>';
        }
        //定义删除按钮样式，只有管理员或自己编辑的任务才有权删除
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_del = '&nbsp;<a href="/delrecord/'+rowobj['id']+'" class="btn-sm btn-danger" onClick="return confirm(&quot;确定删除该解析记录吗?&quot;)">';
        }else{
            var style_del = '&nbsp;<a class="btn-sm btn-danger" disabled>';
        }

        return [
            style_action,
                '<i class="fa fa-power-off"> 开关</i>',
            '</a>', 

            style_del,
                '<i class="fa fa-times"> 删除</i>',
            '</a>'
        ].join('');
    }

    /**添加弹出框*/
    $('#addrecord').click(function(){
        $('#modalTitle').html('添加记录');
        $('#hidInput').val('0');
        $('#myModal').modal('show');
        document.getElementById("host").readOnly=false;
        $('#modalForm')[0].reset();
        isEdit = 0;
    });

    /**
    *修改弹出框
    */
    
    $('#editrecord').popover({
            html: true,
            container: 'body',
            content : "<h3 class='btn btn-danger'>请选择一条进行操作</h3>",
            animation: false,
            placement : "top"
    }).on('click',function(){
            var result = $("#myLoadTable").bootstrapTable('getSelections');
            if(result.length <= 0){
                $(this).popover("show");
                setTimeout("$('#editrecord').popover('hide')",1000)
            }
            if(result.length > 1){
                $(this).popover("show");
                setTimeout("$('#editrecord').popover('hide')",1000)
            }
            if(result.length == 1){
                $('#changedomain').popover('hide');
                $('#host').val(result[0]['host']);
                $('#rtype').val(result[0]['type']);
                $('#mx_priority').val(result[0]['mx_priority']);
                $('#view').val(result[0]['view']);
                $('#data').val(result[0]['data']);
                $('#ttl').val(result[0]['ttl']);
                $('#autoupdate').val(result[0]['autoupdate']);
                $('#comment').val(result[0]['comment']);
                $('#myModal').modal('show');
                $('#rtype').click();
                document.getElementById("host").readOnly=true;
                editId = result[0]['id'];
                isEdit = 1;
            }
     });

    /**提交按钮操作*/
    $("#subBtn").click(function(){
           var zone = "{{domainid}}";
           var host = $('#host').val();
           var rtype = $('#rtype').val();
           var mx_priority = $('#mx_priority').val();
           var view = $('#view').val();
           var data = $('#data').val();
           var ttl = $('#ttl').val();
           var autoupdate = $('#autoupdate').val();
           var comment = $('#comment').val();
           var postUrl;
           if(isEdit==1){
                postUrl = "/editrecord/"+editId;           //修改路径
           }else{
                postUrl = "/addrecord";          //添加路径
           }

           $.post(postUrl,{zone:zone,host:host,rtype:rtype,mx_priority:mx_priority,view:view,data:data,ttl:ttl,autoupdate:autoupdate,comment:comment},function(data){
                  if(data==0){
                    $('#myModal').modal('hide');
                    $('#myLoadTable').bootstrapTable('refresh');
                    //alert("操作成功,");
                    message.message_show(200,200,'成功','操作成功');   
                  }else{
                    message.message_show(200,200,'失败','域名格式错误或其他原因，请检查');
                }
            },'html');
       });

})
</script>

<script language="JavaScript" type="text/javascript">
$(function() {
  $('#rtype').click(function() {
    if (this.value == 'MX') {
        //document.getElementById("dname").innerHTML="域名名称" ;
        //document.getElementById("selInput").readOnly=false ;
        $('#mx_push').show();
        $('#a_push').hide();
    } else if(this.value == 'A'){
        $('#mx_push').hide();
        $('#a_push').show();
    } else {
        //document.getElementById("dname").innerHTML="域名名称" ;
        //document.getElementById("selInput").readOnly=true ;
        //$('#domainA').show();
        $('#mx_push').hide();
        $('#a_push').hide();
    }
  });
  $('#rtype').click();
});
</script>
