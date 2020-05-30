%rebase base position='域名管理',managetopli="active open",adddomain="active"

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">域名列表</span>
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
                            <a id="adddomain" href="javascript:void(0);" class="btn  btn-primary ">
                                <i class="btn-label fa fa-plus"></i>添加域名
                            </a>
                            <a id="changedomain" href="javascript:void(0);" class="btn btn-warning shiny ">
                                <i class="btn-label fa fa-cog"></i>修改域名
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
           <span class="widget-caption themeprimary" id="modalTitle">添加域名</span>
         </div>

         <div class="modal-body">
            <div>
            <form id="modalForm">
                <div class="form-group">
                  <label class="control-label" for="inputSuccess1">域名名称：</label>
                  <input type="text" class="form-control" onkeyup="value=value.replace(/[^\w\.\-\/]/ig,'')" id="domain" name="domain" placeholder="" required>
                </div>
                <div class="form-group">
                  <label class="control-label" for="inputSuccess1">域名类型：</label>
                  <select id="domaintype" style="width:100%;" name="domaintype">
                    <option value='gTLD'>gTLD</option>
                 </select>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">备注信息：</label>
                  <textarea id="comment" name="comment" style="height:70px;width:100%;" ></textarea>
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
          url: '/api/getdomainlist',
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
          sortName: 'domain',
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
              field: 'domain',
              title: '域名名称',
              align: 'center',
              valign: 'middle',
              sortable: true
          },{
              field: 'comment',
              title: '域名描述',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'domaintype',
              title: '域名类型',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'etime',
              title: '创建时间',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'status',
              title: '服务状态',
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
               var style_action = '<a href="/chgstatus/domaindisable/'+rowobj['id']+'" class="btn-sm btn-success" >';
            }else{
               var style_action = '<a href="/chgstatus/domainactive/'+rowobj['id']+'" class="btn-sm btn-danger active" >';
            }
        }else{
            var style_action = '<a class="btn-sm btn-info" disabled>';
        }
        //定义编辑按钮样式，只有管理员或自己编辑的任务才有权编辑
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_edit = '&nbsp;<a href="/recordconf/'+rowobj['domain']+'" class="btn-sm btn-info" >';
        }else{
            var style_edit = '&nbsp;<a class="btn-sm btn-info" disabled>';
        }
        //定义删除按钮样式，只有管理员或自己编辑的任务才有权删除
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_del = '&nbsp;<a href="/deldomain/'+rowobj['domain']+'" class="btn-sm btn-danger" onClick="return confirm(&quot;确定删除该域名及相关解析记录吗?&quot;)">';
        }else{
            var style_del = '&nbsp;<a class="btn-sm btn-danger" disabled>';
        }

        return [
            style_action,
                '<i class="fa fa-power-off"> 开关</i>',
            '</a>', 

            style_edit,
                '<i class="fa fa-edit"> 解析</i>',
            '</a>',

            style_del,
                '<i class="fa fa-times"> 删除</i>',
            '</a>'
        ].join('');
    }

    /**添加弹出框*/
    $('#adddomain').click(function(){
        $('#modalTitle').html('添加用户');
        $('#hidInput').val('0');
        $('#myModal').modal('show');
        $('#modalForm')[0].reset();
        isEdit = 0;
    });

    /**
    *修改弹出框
    */
    
    $('#changedomain').popover({
            html: true,
            container: 'body',
            content : "<h3 class='btn btn-danger'>请选择一条进行操作</h3>",
            animation: false,
            placement : "top"
    }).on('click',function(){
            var result = $("#myLoadTable").bootstrapTable('getSelections');
            if(result.length <= 0){
                $(this).popover("show");
                setTimeout("$('#changedomain').popover('hide')",1000)
            }
            if(result.length > 1){
                $(this).popover("show");
                setTimeout("$('#changedomain').popover('hide')",1000)
            }
            if(result.length == 1){
                $('#changedomain').popover('hide');
                $('#domain').val(result[0]['domain']);
                $('#domaintype').val(result[0]['domaintype']);
                $('#comment').val(result[0]['comment']);
                $('#myModal').modal('show');
                document.getElementById("domain").readOnly=true;
                editId = result[0]['id'];
                isEdit = 1;
            }
     });

    /**提交按钮操作*/
    $("#subBtn").click(function(){
           var domain = $('#domain').val();
           var domaintype = $('#domaintype').val();
           var comment = $('#comment').val();
           var postUrl;
           if(isEdit==1){
                postUrl = "/changedomain/"+editId;           //修改路径
           }else{
                postUrl = "/adddomain";          //添加路径
           }

           $.post(postUrl,{domain:domain,domaintype:domaintype,comment:comment},function(data){
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
