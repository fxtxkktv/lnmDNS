%rebase base position='AIDNS',managetopli="active open",adddomain="active"

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">自定义地址库</span>
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
                            <a id="addaidns" href="javascript:void(0);" class="btn  btn-primary ">
                                <i class="btn-label fa fa-plus"></i>添加地址库
                            </a>
                            <a id="changeaidns" href="javascript:void(0);" class="btn btn-warning shiny ">
                                <i class="btn-label fa fa-cog"></i>修改地址库
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
                  <label class="control-label" for="inputSuccess1">地址库代号：</label>
                  <input type="text" class="form-control" onkeyup="value=value.replace(/[^\w\.\-\_]/ig,'')" id="setname" name="setname" placeholder="" required>
                </div>
                <div class="form-group">
                  <label class="control-label" for="inputSuccess1">地址库描述：</label>
                  <input type="text" class="form-control" id="setdesc" name="setdesc" placeholder="" required>
               </div>
               <div class="form-group">
                  <label class="control-label" for="inputSuccess1">地址集合：</label>
                  <textarea id="setdata" name="setdata" style="height:200px;width:100%;" ></textarea>
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
          url: '/api/getaidnslist',
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
              field: 'setname',
              title: '地址库代号',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'setdesc',
              title: '地址库描述',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'setdt',
              title: '地址集合',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'utime',
              title: '更新时间',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'status',
              title: '可用状态',
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
               var style_action = '<a href="/chgstatus/aidnsdisable/'+rowobj['id']+'" class="btn-sm btn-success" >';
            }else{
               var style_action = '<a href="/chgstatus/aidnsactive/'+rowobj['id']+'" class="btn-sm btn-danger active" >';
            }
        }else{
            var style_action = '<a class="btn-sm btn-info" disabled>';
        }
        //定义删除按钮样式，只有管理员或自己编辑的任务才有权删除
        if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['userid']){
            var style_del = '&nbsp;<a href="/delaidns/'+rowobj['id']+'" class="btn-sm btn-danger" onClick="return confirm(&quot;确定删除该解析线路吗?&quot;)">';
        }else{
            var style_del = '&nbsp;<a class="btn-sm btn-danger" disabled>';
        }

        if ( rowobj['id'] < 7 ){
           return '禁止停用或删除'
        }else{
        return [
            style_action,
                '<i class="fa fa-power-off"> 开关</i>',
            '</a>', 

            style_del,
                '<i class="fa fa-times"> 删除</i>',
            '</a>'
        ].join('');
        }
    }

    /**添加弹出框*/
    $('#addaidns').click(function(){
        $('#modalTitle').html('添加用户');
        $('#hidInput').val('0');
        $('#myModal').modal('show');
        document.getElementById("setname").readOnly=false;
        document.getElementById("setdesc").readOnly=false;
        $('#modalForm')[0].reset();
        isEdit = 0;
    });

    /**
    *修改弹出框
    */
    
    $('#changeaidns').popover({
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
                $('#setname').val(result[0]['setname']);
                $('#setdesc').val(result[0]['setdesc']);
                $('#setdata').val(result[0]['setdata']);
                $('#myModal').modal('show');
                document.getElementById("setname").readOnly=true;
                document.getElementById("setdesc").readOnly=true;
                editId = result[0]['id'];
                isEdit = 1;
            }
     });

    /**提交按钮操作*/
    $("#subBtn").click(function(){
           var setname = $('#setname').val();
           var setdesc = $('#setdesc').val();
           var setdata = $('#setdata').val();
           var postUrl;
           if(isEdit==1){
                postUrl = "/changeaidns/"+editId;           //修改路径
           }else{
                postUrl = "/addaidns";          //添加路径
           }

           $.post(postUrl,{setname:setname,setdesc:setdesc,setdata:setdata},function(data){
                  if(data==0){
                    $('#myModal').modal('hide');
                    $('#myLoadTable').bootstrapTable('refresh');
                    //alert("操作成功,");
                    message.message_show(200,200,'成功','操作成功');   
                  }else{
                    message.message_show(200,200,'失败','地址格式错误或其他原因，请检查');
                }
            },'html');
       });

})
</script>
