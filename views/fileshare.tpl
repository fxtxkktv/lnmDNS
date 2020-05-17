%rebase base position='文件管理'
<script src="/assets/js/clipboard/clipboard.min.js"></script>
<script src="/assets/js/uploadFile.js"></script>

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">文件分享</span>
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
                            <a id="addfileshare" href="javascript:void(0);" class="btn btn-primary ">
                                <i class="btn-label fa fa-cloud-upload"></i>文件上传
                            </a>
                            <div class="btn-group" style="float:right;">
                              <button class="btn btn-success dropdown-toggle" style="min-width:105px;margin:0 auto; float:right ;" data-toggle="dropdown" type="button">
                                <i class="btn-label fa fa-list-ul"></i>&nbsp;选择目录
                              </button>
                              <ul class="dropdown-menu" style="min-width:105px;margin:0 auto;">
                                <li><a class="btn btn-success" href="/fileshare/root">默认目录</a></li>
                                %for dir in ftpdirs:
                                  <li><a class="btn btn-success" href="/fileshare/{{dir}}">{{dir}}</a></li>
                                %end
                              </ul>
                            </div>
                            &nbsp;
                            %if msg.get('message'):
                                <span style="color:{{msg.get('color','')}};font-weight:bold;">{{msg.get('message','')}}</span>
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
           <span class="widget-caption themeprimary" id="modalTitle">新增文件</span>
        </div>
      <div class="modal-body">
        <div>
            <form id="modalForm" enctype="multipart/form-data" >
             <div class="form-group">
                  <label class="control-label" for="inputSuccess1">存储目录：</label>
                  <select id="dstdir" style="width:100%;" name="dstdir">
                    <option value='/'>默认目录</option>
                    %for dir in ftpdirs:
                       <option value="{{dir}}">{{dir}}</option>
                    %end
                 </select>
             </div>
             <div class="form-group">
                  <label class="control-label" for="inputSuccess1">上传文件至FTP接口:</label>
                     <div class="form-control">
                       <div class="upload-block" id="selectUploadFile">
                        <form id="fileForm" class="" enctype="multipart/form-data" method="post" name="fileinfo">
                        <input type="file" accept=".jpg,.bmp,.txt,.zip,.rar,.xls,.xlsx,.doc,.docx,.pdf" id="upload" name="upload" draggable="true"/>
                        <input type="hidden" name="filepath" value="" />
                        <div id="progress" class="progress"></div>
                        </form>
                        </div>
                     </div>
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
<script src="/assets/js/datetime/bootstrap-datepicker.js"></script>
<script type="text/javascript">
$(function(){
    /**
    *表格数据
    */
    var editId;        //定义全局操作数据变量
    var isEdit;
    $('#myLoadTable').bootstrapTable({
          method: 'post',
          url: '/api/getfileshareinfo/{{path}}',
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
              field: 'name',
              title: '文件名称',
              align: 'center',
              valign: 'middle',
              sortable: false,
          },{
              field: 'time',
              title: '创建时间',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: 'size',
              title: '文件大小',
              align: 'center',
	      valign: 'middle',
              sortable: false
	 },{
              field: '',
              title: '操作',
              align: 'center',
              valign: 'middle',
              width:200,
              formatter:getinfo
          }]
      });

    //定义列操作
    function getinfo(value,row,index){
        eval('rowobj='+JSON.stringify(row));
        //定义编辑按钮样式，只有管理员或自己编辑的任务才有权编辑
        //if("{{session.get('username',None)}}" ){
        //    var style_del = '&nbsp;<a href="/delftpobj/'+rowobj['name']+'" class="btn-sm btn-danger" onClick="return confirm(&quot;确定删除?&quot;)"> ';
        //}else{
        //    var style_del = '&nbsp;<a class="btn-sm btn-danger" disabled>';
        //}
        //定义删除按钮样式，只有管理员或自己编辑的任务才有权删除
        if("{{session.get('username',None)}}"){
            var style_download = '&nbsp;<a href="https://www.filezilla.cn/download" target="_bank" class="btn-sm btn-info" onClick="return confirm(&quot;推荐使用FileZila客户端操作...&quot;)"> ';
        }else{
            var style_download = '&nbsp;<a class="btn-sm btn-info" disabled>';
        }

        return [
            //style_del,
            //    '<i class="fa fa-download"> 下载或删除</i>',
            //'</a>',

            style_download,
                '<i class="fa fa-download"> 下载或删除</i>',
            '</a>'
        ].join('');
    }

    $('#addfileshare').click(function(){
        $('#progress').hide(); //重置进度条显示
        $('#modalTitle').html('新增文件');
        $('#hidInput').val('0');
        $('#myModal').modal('show');
        $('#modalForm')[0].reset();
        isEdit = 0;
    });
    
    /**
    *提交按钮操作
    */
    $("#subBtn").click(function(){
           var dstdir = $('#dstdir').val();
           var ufile = document.getElementById("upload").files[0];
           try {
               var fname = ufile.name;
               var fsize = ufile.size;
               var fdesc = new Blob([window.fileString]);
               var ftype = (fname.substr(fname.lastIndexOf("."))).toLowerCase();
               if ( fsize > 52428800 ){
                  alert("文件不应该大于500M，请压缩后重新上传");
                  return false;
               }
               if( ftype != ".txt" && ftype != ".rar" && ftype != ".zip" && ftype != ".doc" && ftype != ".docx" && ftype != ".xls" && ftype != ".xlsx" && ftype != ".pdf" && ftype != ".jpg" && ftype != ".bmp"){
                alert("您上传文件类型不符合(.txt|.rar|.zip|.pdf|.doc(x)|.xls(x))");
                return false;
              }
           } catch (e){
               var fname = '';
               var fsize = '';
               var ftype = '';
               var fdesc = '';
           }

         //ajax方式
           var fd = new FormData();
           fd.append('dstdir', dstdir)
           fd.append('fname', fname);
           fd.append('fdesc', fdesc);
           $.ajax({
            type: 'POST',
            url: "/addfileshare",
            data: fd,
            processData: false,
            contentType: false
            }).done(function(data) {
                if(data==0){
                    $('#myModal').modal('hide');
                    $('#myLoadTable').bootstrapTable('refresh');
                    message.message_show(200,200,'成功','操作成功');   
                  }else if(data==-1){
                      message.message_show(200,200,'失败','操作失败');
                  }else if(data==-2){
                      message.message_show(200,200,'失败','FTP连接异常');
                  }else{
                        message.message_show(200,200,'添加失败','填写不完整');return false;
                }
            });
       });

//处理上传进度条显示
var sUploadFile = new SgyUploadFile({
    uploadProgress: function(evt){
    $('#progress').show();
    if (evt.lengthComputable) {
       var percentComplete = Math.round(evt.loaded * 100 / evt.total);
       $('.progress').html("上传文件进度"+percentComplete+"%");
       }
    },
    uploadError: function( result ) {
      // 上传失败关闭进度条
      $('#upload').val('');
    },
    uploadSuccess:function( result ) {
      if(result.error_code == 0) {
        $('#upload').val('');
      }
    }
});

$('#upload').on( 'change', function( event ) {
 var el  = event.srcElement || event.target;
 var fileName = el.value;
 var files = el.files;
 if(files.length == 1) {
    var file = files[ 0 ];
    sUploadFile.ajaxUpload({
    formData:sUploadFile.wrapperFormDate(file, fileName),
    fileName:fileName
    });
    }
} );

window.onload=function(){
       var f = document.getElementById("upload");  
       //this.files即获取input中上传的file对象 是个数组   
       f.onchange = function(){  
           var files = $('#upload').prop('files');//获取到文件列表
           var reader = new FileReader();//新建一个FileReader
           reader.readAsArrayBuffer(files[0]); //读取文件
           //reader.readAsText(files[0],'gb2312');  //base64读取 
           reader.onload = function(evt){ //读取完文件之后会回来这里
              window.fileString = evt.target.result; // 读取文件内容
           }
       }     
   }
})

function myCopy(){
	var ele = document.getElementById("textdata");
	ele.select();
	document.execCommand("Copy");
	alert("复制成功");
}
var clipboard = new Clipboard('.btncwf');
clipboard.on('success', function(e) {
        /*$.ajax({
            type: 'POST',
            url: "/makesharesign",
            data: fd,
            processData: false,
            contentType: false
            }).done(function(data) {
                if(data==0){
                    $('#myModal').modal('hide');
                    $('#myLoadTable').bootstrapTable('refresh');
                    message.message_show(200,200,'成功','操作成功');   
                  }else if(data==-1){
                      message.message_show(200,200,'失败','操作失败');
                  }else{
                        message.message_show(200,200,'添加失败','填写不完整');return false;
                }
            });*/
        alert("链接已复制到剪切板");
 });
clipboard.on('error', function(e) {
    console.log(e);
  });

</script>
