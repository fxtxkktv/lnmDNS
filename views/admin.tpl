%rebase base position='用户管理',managetopli="active open",adduser="active"

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">用户列表</span>
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
                            <a id="adduser" href="javascript:void(0);" class="btn  btn-primary ">
                                <i class="btn-label fa fa-plus"></i>添加用户
                            </a>
                            <a id="changeuser" href="javascript:void(0);" class="btn btn-warning shiny">
                                <i class="btn-label fa fa-cog"></i>修改用户
                            </a>
                            <a id="deluser" href="javascript:void(0);" class="btn btn-darkorange">
                                <i class="btn-label fa fa-times"></i>删除用户
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
           <span class="widget-caption themeprimary" id="modalTitle">添加用户</span>
         </div>

         <div class="modal-body">
            <div>
            <form id="modalForm">
                <div class="form-group">
                  <label class="control-label" for="inputSuccess1">帐号：</label>
                  <input type="text" class="form-control" onkeyup="value=value.replace(/[^\w\.\/]/ig,'')" id="username" name="username" placeholder="由字母、数字组成(特殊符号除外)，至少4位以上" require>
                </div>
                <div class="form-group">
                  <label class="control-label" for="inputSuccess1">密码：</label>
                  <input type="password" class="form-control" id="password" name="password" placeholder="由字母、数字组成、符号，至少8位以上" require>
                </div>
                <div class="form-group">
                  <label class="control-label" for="inputSuccess1">用户状态：</label>
                  <select id="ustatus" style="width:100%;" name="ustatus">
                    <option value='1'>启用</option>
                    <option value='0'>禁用</option>
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
          url: '/api/getadmin',
          contentType: "application/json",
          datatype: "json",
          cache: false,
          checkboxHeader: true,
          striped: true,
          pagination: true,
          pageSize: 15,
          pageList: [10,20,50],
          search: true,
          showColumns: true,
          showRefresh: true,
          minimumCountColumns: 2,
          clickToSelect: true,
          smartDisplay: true,
          //sidePagination : "server",
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
              //sortable: false,
	      formatter:function(value,row,index){
                return index+1;
              }
          },{

              field: 'username',
              title: '帐号',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{ 
              field: 'comment',
              title: '备注信息',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'adddate',
              title: '创建日期',
              align: 'center',
              valign: 'middle',
              visible: false,
              sortable: false
          },{
              field: 'ustatus',
              title: '状态',
              align: 'center',
              valign: 'middle',
              sortable: false,
              formatter: function(value,row,index){
                        if( value == '1' ){
                                return '有效';
                        }else{  return '禁用';
                        }
              }
          }]
      });

    /**
    *添加弹出框
    */

    $('#adduser').click(function(){
        $('#modalTitle').html('添加用户');
        $('#hidInput').val('0');
        $('#myModal').modal('show');
        $('#modalForm')[0].reset();
        isEdit = 0;
    });


    /**
    *修改弹出框
    */
    
    $('#changeuser').popover({
    	    html: true,
    	    container: 'body',
    	    content : "<h3 class='btn btn-danger'>请选择一条进行操作</h3>",
    	    animation: false,
    	    placement : "top"
    }).on('click',function(){
    		var result = $("#myLoadTable").bootstrapTable('getSelections');
    		if(result.length <= 0){
    			$(this).popover("show");
    			setTimeout("$('#changeuser').popover('hide')",1000)
    		}
    		if(result.length > 1){
    			$(this).popover("show");
    			setTimeout("$('#changeuser').popover('hide')",1000)
    		}
    		if(result.length == 1){
                $('#changeuser').popover('hide');
                $('#username').val(result[0]['username']);
                $('#passwd').val(result[0]['passwd']);
                $('#ustatus').val(result[0]['ustatus']);
                $('#comment').val(result[0]['comment']);
                $('#modalTitle').html('修改用户');     //头部修改
                $('#hidInput').val('1');            //修改标志
                $('#myModal').modal('show');
                document.getElementById("username").readOnly=true;
                editId = result[0]['id'];
                isEdit = 1;
    		}
        });

    /**
    *提交按钮操作
    */
    $("#subBtn").click(function(){
           var username = $('#username').val();
           var password = $('#password').val();
           var ustatus = $('#ustatus').val();
           var comment = $('#comment').val();
           var access = "1";
           var postUrl;
           if(isEdit==1){
                postUrl = "/changeuser/"+editId;           //修改路径
           }else{
                postUrl = "/adduser";          //添加路径
           }

           $.post(postUrl,{username:username,password:password,ustatus:ustatus,comment:comment,access:access},function(data){
                  if(data==0){
                    $('#myModal').modal('hide');
                    $('#myLoadTable').bootstrapTable('refresh');
                    //alert("操作成功,");
                    message.message_show(200,200,'成功','操作成功');   
                  }else if(data==-1){
                      message.message_show(200,200,'失败','操作失败');
                  }else{
                      message.message_show(200,200,'添加失败','表单数据填写错误(用户名长度、密码长度等)');return false;
                }
            },'html');
       });

        /**
        *删除按钮操作
        */        
    $('#deluser').popover({
                html: true,
                container: 'body',
                content : "<h3 class='btn btn-danger'>请选择要删除的记录</h3>",
                animation: false,
                placement : "top"
        }).on('click',function(){
            var res = $("#myLoadTable").bootstrapTable('getSelections');
            var str = '';
            if(res.length <= 0){
                $(this).popover("show");
                setTimeout("$('#deluser').popover('hide')",1000)
            }else{
		var r = confirm("确定要删除用户吗？");
                if (r==false){
                        $('myLoadTable').bootstrapTable('refresh');
                        console.log(data);
			return false;
                }
                $(this).popover("hide");
                for(i in res){
                    str += res[i]['id']+',';
                }
                $.post('/deluser',{str:str},function(data){
                    if(data==0){
                        message.message_show(200,200,'删除成功',res.length+'条记录被删除');
                        $('#myLoadTable').bootstrapTable('refresh');
                    }else{
                        message.message_show(200,200,'失败','删除失败');
                    }
                },'html');  
                
            }
        });
        
})
</script>
