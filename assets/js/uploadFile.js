/**
 * 支持Ajax的上传组件
 * 采用FormData对象
 * @param options
 * @constructor
 */
function SgyUploadFile ( options ) {
  this.fileSuffix = [ 'rar', 'doc', 'docx', 'bin', 'tar', 'tgz', 'tar.gz', 'pdf', 'zip', 'xls', 'xlsx', 'ppt', 'pptx' ];
  this.options = options || {};
  /**
   * 上传文件，在回调函数中处理数据
   * @param formData
   * @param callback
   */
  this._ajax = function( formData, callback ) {
    var that = this;
    try {
      $.ajax( {
        type:'post',
        typeData:'json',
        url:'/onlyprocesspage',
        data:formData,
        processData:false,  // 不处理数据
        contentType:false,   // 不设置内容类型
        xhr: function() {
          var xhr = new window.XMLHttpRequest();
          //Upload progress
          xhr.upload.addEventListener("progress", function(evt){
            that.options.uploadProgress(evt);
          }, false);
          return xhr;
        },
      } ).done( function( result ) {
        if ( result.error_code == 0 ) {
          that.options.uploadSuccess(result);
        } else {
          that.options.uploadError(result);
        }
      } );
    } catch (e) {
      that.options.uploadError({});
      alert('上传失败');
      throw('上传失败');
    }
  }
  /**
   * 查检文件名后缀格式
   * @param fileName 文件名或文件全路径
   * @returns {boolean} 验证成功返回true 否则返回false
   */
  this._checkFileName =   function ( fileName ) {
    
    // 验证字符串及是否为空
    if ( $.type(fileName) != "string" && $.trim(fileName) == "" ) {
      return false;
    }
    
    // 过滤匹配到的后缀个数
    var filter = this.fileSuffix.filter( function( item ) {
      return fileName.indexOf( '.' + item ) > -1;
    } )
    
    // 如果返回的数组结果个为0，证明未匹配到文件后缀
    // 返回false
    if ( filter.length == 0 ) {
      return false;
    }
    return true;
  }
  /**
   * 上传入口
   * @param formData 文件对象
   * @param fileName 文件名
   * @param callback 回调
   */
  this.ajaxUpload = function( option ) {
    /**
     * 1.验证上传文件格式
     * 2.开始上传
     * 3.上传完成后回调
     */
    var check = this._checkFileName(option.fileName);
    
    if( check ) {
      this._ajax(option.formData);
     } else {
      this.options.uploadError({});
      alert('上传文件格式不正确');
    }
  }
  this.wrapperFormDate = function (file) {
    var formData= new FormData();
    formData.append('cv', file);
    return formData;
  }
}
document.addEventListener( 'dragover', function( e ) {
  e.stopPropagation();
  e.preventDefault();
}, false );
document.addEventListener( 'drop', function( e ) {
  e.stopPropagation();
  e.preventDefault();
}, false );
