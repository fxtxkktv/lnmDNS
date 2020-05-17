
<!-- Page Sidebar -->
<div class="page-sidebar" id="sidebar">
    <!-- Page Sidebar Header-->
    <!--div class="sidebar-header-wrapper">
        <input type="text" class="searchinput" />
        <i class="searchicon fa fa-search"></i>
        <div class="searchhelper">搜索</div>
    </div-->
    <!-- /Page Sidebar Header -->

    <!-- Sidebar Menu -->
    <ul class="nav sidebar-menu">
        <!--Dashboard-->
        <li>
            <a href="/project">
                <i class="menu-icon glyphicon glyphicon-home"></i>
                <span class="menu-text"> 欢迎主页 </span>
            </a>
        </li>
	%if session.get('access','') == 1 :
        <li class="active open">
            <a href="#" class="menu-dropdown">
                <i class="menu-icon fa fa-desktop"></i>
                <span class="menu-text"> 系统配置</span>
                <i class="menu-expand"></i>
            </a>
            <ul class="submenu">
                <li class="">
                    <a href="/systeminfo">
                        <span class="menu-text">系统信息</span>
                    </a>
                </li>
                <li class="">
                  <a href="/resconfig">
                  <span class="menu-text">监控配置</span>
                  </a>
                </li>
                <li class="">
                    <a href="/administrator">
                        <span class="menu-text">管&nbsp;理&nbsp;员</span>
                    </a>
                </li>
                <li class="">
                    <a href="/backupset">
                        <span class="menu-text">数据备份</span>
                    </a>
                </li>
            </ul>
        </li>
        %end
        <li class="active open">
            <a href="#" class="menu-dropdown">
                <i class="menu-icon fa fa-tasks"></i>
                <span class="menu-text"> 解析管理 </span>
                <i class="menu-expand"></i>
            </a>
            <ul class="submenu">
            %if session.get('access','') == 1 :
                <li class="">
                    <a href="/dnsservconf">
                        <span class="menu-text">全局设置</span>
                    </a>
                </li>
                <li class="">
                    <a href="/domainlist">
                        <span class="menu-text">域名列表</span>
                    </a>
                </li>
                <li class="">
                    <a href="/aidns">
                        <span class="menu-text">AIDNS库</span>
                    </a>
                </li>
                <li class="">
                    <a href="/showlog">
                        <span class="menu-text">解析记录</span>
                    </a>
                </li>
            %end
            </ul>
        </li>

	<li class="active open">
            <a href="#" class="menu-dropdown">
                <i class="menu-icon fa fa-tty"></i>
                <span class="menu-text"> 帮助文档 </span>
                <i class="menu-expand"></i>
            </a>
            <ul class="submenu">
                <li class="">
                    <a href="/clientdownload">
                        <span class="menu-text">文件下载</span>
                    </a>
                </li>
                <!--li class="">
                    <a href="/resolvent">
                        <span class="menu-text">常见问题</span>
                    </a>
                </li-->
                <li class="">
                    <a href="/support">
                        <span class="menu-text">问题反馈</span>
                    </a>
                </li>
            </ul>
        </li>
        <li class="active">
            <a href="https://github.com/fxtxkktv" target="_bank" class="menu-dropdown">
                <i class="menu-icon fa fa-address-book-o"></i>
                <span class="menu-text"> AboutMe </span>
                <i class="menu-expand"></i>
            </a>
       </li>
    </li>
    </ul>
    <!-- /Sidebar Menu -->
</div>
<!-- /Page Sidebar -->
<!-- Page Content -->
