(function(win, $) {
	var $win = $(win), $bd = $('body'), $doc = $(document);

	// 以下api按照功能来区分，定义命名空间以ead开头

	/*
	 * 更改本地UI
	 */
	win.eadUpdateLocalUI = {
		// 更改标题
		setTitle : function(title) {
			window.apicore.setTitle(title);
		}
	};
	
	/*
	 * 文件操作
	 */
	win.eadFile = {
		// 打开文件
		openFile : function(filepath) {
			window.apicore.openFile(filepath);
		},
		
		// 打开文件选择器
		openFileChoose : function() {
			window.apicore.openFileChoose();
		}

	};

	/*
	 * 设备功能
	 */
	win.eadPhone = {
		//打电话
		call : function(callnum) {
			window.apicore.call(callnum);
		},
		//发短信
		sendMsg : function(callnum,body) {
			window.apicore.sendMsg(callnum,body);
		},
		//拍照
		takePhoto: function(photoname) {
			window.apicore.takePhoto(photoname);
		},
		//打开本地图库
		openImageChoose : function() {
			window.apicore.openImageChoose();
		},
		//打开本地录音功能
		openAudio : function() {
			window.apicore.openAudio();
		}
	};
	
	/*
	 * 日期选择
	 */
	win.eadDate = {
		//选择年月日
		openDatePick  : function(y,m,d) {
			window.apicore.openDatePick(y,m,d);
		},
		//选择时分
		openTimePick  : function(h,m) {
			window.apicore.openTimePick(h,m);
		}
		
	};
	
	/*
	 * 地图功能
	 */
	win.eadMap = {
		//打开地图
		openMap  : function() {
			window.apicore.openMap();
		}
		
	};
	
	//==============南京智慧社区项目个性化api=============================
	/*
	 * CA加密
	 */
	win.eadCA = {
		//证书下载
		saveCert  : function(privateCert) {
//			window.apicore.saveCert(privateCert);
            var img = createImageWithBase64(imageData);
            document.getElementById("cameraWrapper").appendChild(img);
		},
		//ca加密
		encrypt  : function(content,publicCert) {
			window.apicore.encrypt(content,publicCert);
		}
 
        
 
	};
	

}(this, jQuery));