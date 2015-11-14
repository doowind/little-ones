package  {
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.FocusEvent;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.StageScaleMode;
	import com.adobe.images.BitString;
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;
	import flash.net.FileReference;
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import fl.events.ColorPickerEvent;
	import flash.media.CameraRoll;
	import flash.desktop.NativeApplication;
	import flash.ui.Keyboard;
	
	public class Main extends MovieClip {
		
		private var m_string:String;
		private var startInput:Boolean = false;
		private var m_stageWidth:int = 0;
		private var m_stageHeight:int = 0;
		
		private var m_bitmap:Bitmap = new Bitmap();
		
		private const GAP_X:int = 80;
		private const GAP_Y:int = 30;
		private var m_center:Point = new Point(0, 0);
		
		private var m_gap_check:Point = new Point();
		private var m_gap_print:Point = new Point();
		private var m_gap_text:Point = new Point();
		private var m_gap_color:Point = new Point();
		private var m_gap_info:Point = new Point();
		
		private var m_imageContainer:MovieClip;
		private var m_BG:Shape;
		private var m_curBgColor:uint;
		private var m_curLabelCoror:uint;
		private var m_lableArr:Array;
		
		private var m_originWidth:Number;
		private var m_originHeight:Number;
		
		private var m_saveFile:FileReference = new FileReference();
		private var m_osInfo:String;
		private var m_carmeraRoll:CameraRoll;
		public function Main() {
			// constructor code
			init();
		}
		
		private function init()
		{
			//var nativeOperationSystem:String = Capabilities.os;
			mc_savePic.gotoAndStop(1);
			mc_confirm.visible = false;
			
			this.addEventListener("playEnd", hideMCSave);
			var info:Array = Capabilities.os.split(" ");
			m_osInfo = info[0];
		//	outPutLabel.appendText("OS :"+m_osInfo+ "\n");
		//	outPutLabel.appendText("Originsize :" + stage.stageWidth + "," + stage.stageHeight + "\n");
			if (m_osInfo == "Linux" || m_osInfo == "Android")
			{
				NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
			}
			
			
			stop();
			mc_savePic.visible = false;
			m_carmeraRoll = new CameraRoll();
			m_carmeraRoll.addEventListener(Event.COMPLETE, onSavePicComplete);
			m_carmeraRoll.addEventListener(ErrorEvent.ERROR, onSavePicError);
			
			m_originWidth = stage.stageWidth;
			m_originHeight = stage.stageHeight;
			
			m_BG = new Shape();
			m_imageContainer = new MovieClip();
			m_lableArr = new Array();
			
			UIColor.visible = false;
			UIInfo.visible = false;
			
			m_curBgColor = 0x666666;
			m_curLabelCoror = 0xD94537;
			mainLayer.addChild(m_BG);
			m_BG.graphics.beginFill(m_curBgColor);
			m_BG.graphics.drawRect(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
			m_BG.graphics.endFill();
			mainLayer.addChild(m_imageContainer);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			mainLayer.mouseEnabled = false;
			mainLayer.mouseChildren = false;
			m_stageWidth = stage.stageWidth;
			m_stageHeight = stage.stageHeight;
			m_center.x = m_stageWidth * .5;
			m_center.y = m_stageHeight * .5;
			btn_check.addEventListener(MouseEvent.CLICK, onCreate);
			mc_label.x = m_center.x;
			mc_label.y = m_center.y;
			
			UIColor.btnClose.addEventListener(MouseEvent.CLICK, colorClose);
			UIInfo.btnClose.addEventListener(MouseEvent.CLICK, infoClose);
			
			mc_confirm.btn_confirm.addEventListener(MouseEvent.CLICK, exitThis);
			mc_confirm.btn_cancle.addEventListener(MouseEvent.CLICK, cancleExit);
			
			m_gap_check.x = btn_check.x - mc_label.x;
			m_gap_check.y = btn_check.y - mc_label.y;
			
			m_gap_print.x = btnExport.x - mc_label.x;
			m_gap_print.y = btnExport.y - mc_label.y;
			
			m_gap_text.x = btnText.x - mc_label.x;
			m_gap_text.y = btnText.y - mc_label.y;
			
			m_gap_color.x = btnColor.x - mc_label.x;
			m_gap_color.y = btnColor.y - mc_label.y;
			
			m_gap_info.x = btnInfo.x - mc_label.x;
			m_gap_info.y = btnInfo.y - mc_label.y;
			
			mc_label.textInput.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			btnText.addEventListener(MouseEvent.CLICK, onInput);
			btnExport.addEventListener(MouseEvent.CLICK, onExport);
			btnColor.addEventListener(MouseEvent.CLICK, onColor);
			btnInfo.addEventListener(MouseEvent.CLICK, onShowInfo);
			UIColor.picker_bg.addEventListener(ColorPickerEvent.CHANGE, bgColorChangeHandler);
			UIColor.picker_label.addEventListener(ColorPickerEvent.CHANGE, labelColorChangeHandler);
			btnInfo.x = stage.stageWidth - 100;
			btnText.mouseEnabled = false;
			btnExport.mouseEnabled = false;
			btnColor.mouseEnabled = false;
		//	btnInfo.mouseEnabled = false;
			
			btnText.alpha = 0;
			btnExport.alpha = 0;
			btnColor.alpha = 0;
		//	btnInfo.alpha = 0;
			
			m_saveFile.addEventListener(Event.COMPLETE, saveCompleteHandler);
			m_saveFile.addEventListener(IOErrorEvent.IO_ERROR, saveIOErrorHandler);
			
			stage.addEventListener(Event.RESIZE, handleResize);
			handleResize();
		}
		
		private function hideMCSave(e:Event)
		{
			trace("end");
			TweenLite.to(mc_savePic, 0.2, { y: -mc_savePic.height,alpha:0 } );
		}
		
		private function handleKeys(e:KeyboardEvent)
		{
			if (e.keyCode == Keyboard.BACK)
			{
			//	outPutLabel.appendText("不退出!\n");
				e.preventDefault();
				mc_confirm.visible = true;
			}
		}
		
		private  function handleResize(...ig) :void {
		//	mainLayer.x = 0;
		//	mainLayer.y = 0;
		    this.x = -(stage.stageWidth - m_originWidth) * .5;
			this.y = -(stage.stageHeight - m_originHeight) * .5;
			
		/*	outPutLabel.appendText("size :" + stage.stageWidth + "," + stage.stageHeight + "\n");
			outPutLabel.appendText("Mainlayerpos :" + mainLayer.x + "," + mainLayer.y + "\n");
			outPutLabel.appendText("bgPos :" + m_BG.x+ "," + m_BG.y + "\n");*/
			btnInfo.x = stage.stageWidth - 100;
			m_BG.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
			mc_confirm.x = stage.stageWidth / 2;
			mc_confirm.y = stage.stageHeight / 2;
			mc_confirm.bg.width = stage.stageWidth;
			mc_confirm.bg.height = stage.stageHeight;
		// adjust the gui to fit the new device resolution
		}

// call handleResize to initialize the first time

		
		private function bgColorChangeHandler(e:ColorPickerEvent)
		{
		//	trace("color changed:", e.color, "(#" + e.target.hexValue + ")");
			m_BG.graphics.clear();
			var newuint = uint("0x"+e.target.hexValue);
			m_curBgColor = newuint;
			m_BG.graphics.beginFill(m_curBgColor);
			m_BG.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			m_BG.graphics.endFill();
		}
		
		private function labelColorChangeHandler(e:ColorPickerEvent)
		{
		//	trace("label color changed:", e.color, "(#" + e.target.hexValue + ")");
			var newuint = uint("0x"+e.target.hexValue);
			m_curLabelCoror = newuint;
			for (var i:int = 0; i < m_lableArr.length; i++ )
			{
				var labeMc:LableMC = m_lableArr[i];
				labeMc.setColor(m_curLabelCoror);
			}
		}
		
		
		private function saveCompleteHandler(e:Event)
		{
			showSavePicMC();
			trace("done");
		}
		
		private function saveIOErrorHandler(e:IOErrorEvent)
		{
			trace("error--->");
		}
		
		private function onFocusIn(e:FocusEvent)
		{
			if (startInput == false)
			{
				mc_label.textInput.text = "";
				startInput = true;
			}
		}
		
		private function onColor(e:MouseEvent)
		{
			UIColor.visible = true;
			UIInfo.visible = false;
		}
		
		private function onShowInfo(e:MouseEvent)
		{
			if (UIColor.visible == true)
			{
				UIColor.visible = false;
			}
			UIInfo.visible = true;
		}
		
		private function colorClose(e:MouseEvent)
		{
			UIColor.visible = false;
		}
		
		private function infoClose(e:MouseEvent)
		{
			UIInfo.visible = false;
		}
		
		private function exitThis(e:MouseEvent)
		{
			NativeApplication.nativeApplication.exit();
		}
		
		private function cancleExit(e:MouseEvent)
		{
			mc_confirm.visible = false;
		}
		
		private function onInput(e:MouseEvent)
		{
			colorClose(null);
			infoClose(null);
			moveElementsBack();
		}
		
		private function onExport(e:MouseEvent)
		{
			colorClose(null);
			infoClose(null);
			var bmpd:BitmapData = new BitmapData(int(stage.stageWidth), int(stage.stageHeight));
			bmpd.draw(mainLayer);
				
			if (m_osInfo == "Windows")
			{
				
				
			//	m_bitmap.bitmapData = bmpd;
			//	trace("width --> " + bmpd.width + "," + "height --> "+bmpd.height);
				
			//	this.addChild(m_bitmap);
			//	
				var jpgenc:JPGEncoder = new JPGEncoder(95);
			//	var fl:File = File.desktopDirectory.resolvePath(”snapshot.jpg”);
			//	var fileNameRegExp:RegExp = /^(?P<fileName>.*)\..*$/;
			//	var outputFileName:String = fileNameRegExp.exec(_loadFile.name).fileName + "_crop";
				var outputFileName:String = "image";
				outputFileName += ".jpg";
				
				var imgByteArray:ByteArray = jpgenc.encode(bmpd);
				
				m_saveFile.save(imgByteArray, outputFileName);
			}
			else if (m_osInfo == "Linux" || m_osInfo == "Android")
			{
			//	outPutLabel.appendText("save pic to Android :" + "\n");
				m_carmeraRoll.addBitmapData(bmpd);
				
			}
			else if (m_osInfo == "Ios")
			{
				trace("save pic to Ios :" + "\n");
			}
			else 
			{
				trace("未能识别设备");
			}
		//	this.addChild(m_bitmap);
		}
		
		private function onSavePicComplete(e:Event)
		{
		//	outPutLabel.appendText("save success :" + "\n");
			showSavePicMC();
		}
		
		private function onSavePicError(e:Event)
		{
		//	outPutLabel.appendText("save faild :" + "\n");
		}
		
		private function resizeMainLayer()
		{
			var timeX:Number = m_imageContainer.width / stage.stageWidth;
			var timeY:Number = m_imageContainer.height / stage.stageHeight;
			trace("----------> ",m_imageContainer.x,m_imageContainer.y,m_imageContainer.width,m_imageContainer.height,timeX, timeY);
			if (timeX < 1 && timeY < 1)
			{
				return;
			}
			else 
			{
				var finalScale:Number;
				timeX > timeY?finalScale = timeX:finalScale = timeY;
				m_imageContainer.scaleX = 1/finalScale * .9;
				m_imageContainer.scaleY = 1/finalScale * .9;
			//	var firstChild:MovieClip = mainLayer.getChildAt(0) as MovieClip;
			}
		}
		
		private function resetMainLayer()
		{
			while (m_imageContainer.numChildren > 0)
			{
				m_imageContainer.removeChildAt(0);
			}
			m_imageContainer.scaleX = 1;
			m_imageContainer.scaleY = 1;
		}
		
		private function onCreate(e:MouseEvent)
		{
			m_lableArr = [];
			resetMainLayer();
			m_string = mc_label.textInput.text;
			if (m_string == " ")
			{
				return;
			}
			var startY:int = 0;
			var startX:int = 0;
			
			var i:int;
			var lineNum:int = 1;
			var maxLength:int = 0;
			var curMaxLength:int = 0;
			for (i = 0; i < m_string.length; i++)
			{
				curMaxLength ++;
				if (m_string.charCodeAt(i) == 13 || m_string.charCodeAt(i) == 10)
				{
					if (curMaxLength > maxLength)
					{
						maxLength = curMaxLength;
					}
					curMaxLength = 0;
					lineNum++;
				}
			}
			if (lineNum == 1)
			{
				maxLength = curMaxLength;
			}
			var _startX:int = (m_stageWidth - (maxLength * GAP_X + (lineNum - 1) * GAP_X)) / 2; 
			if (_startX < 0)
			{
				_startX = 0;
			}
			var _startY:int = (m_stageHeight - (lineNum * GAP_Y + (maxLength - 1) * GAP_Y)) / 2; 
			if (_startY < 100)
			{
				_startY = 100;
			}
			startX = _startX + lineNum * GAP_X;
			startY = _startY;
			
			
			var curX:int = startX;
			var curY:int = startY;
			for (i = 0; i < m_string.length; i++)
			{
				//回车换行
				if (m_string.charCodeAt(i) == 13 || m_string.charCodeAt(i) == 10)
				{
					startY += GAP_X;
					startX -= GAP_X;
					curY = startY;
					curX = startX;
					continue;
				}
				//空格直接空着
				else if (m_string.charAt(i) == " ")
				{
					curX += GAP_X;
					curY += GAP_Y;
					continue;
				}
				var mc:MovieClip;
				var flag:int = Math.floor(Math.random() * 11) + 1;
				if (flag <= 3)
				{
					mc = new C_Superman();
				}
				else if(flag <= 6)
				{
					mc = new C_Bear();
				}
				else if(flag <= 9)
				{
					mc = new C_Batman();
				}
				else if(flag <= 12)
				{
					mc = new C_Shuibingyue();
				}
				else if(flag <= 15)
				{
					mc = new C_Miao();
				}
				else 
				{
				//	mc = new C_Miao_2();
					mc = new C_Miao();
				}
			//	var mc:C_Superman = new C_Superman();
				m_imageContainer.addChild(mc);
				mc.x = curX;
				mc.y = curY;
				
				curX += GAP_X;
				curY += GAP_Y;
				var label:LableMC = new LableMC();
				label.setLabel(m_string.charAt(i));
				label.setColor(m_curLabelCoror);
				mc.labelPos.addChild(label);
				mc.mouseEnabled = false;
				m_lableArr.push(label);
			}
			resizeMainLayer();
			moveElementsAway();
		}
		
		private function moveElementsAway()
		{
			var desPosx:int = stage.stageWidth + mc_label.width * .5;
			var desPosy:int = stage.stageHeight * .5;
			TweenLite.to(mc_label, .3, { x:desPosx, y:desPosy } );
			desPosx = desPosx + m_gap_check.x;
			desPosy = desPosy + m_gap_check.y;
			TweenLite.to(btn_check, .3, { x:desPosx, y:desPosy } );
			
			desPosx = stage.stageWidth -100;
			btnExport.mouseEnabled = true;
			btnText.mouseEnabled = true;
			btnColor.mouseEnabled = true;
		//	btnInfo.mouseEnabled = true;
			TweenLite.to(btnExport, .3, { x:desPosx,alpha:100 } );
			
			TweenLite.to(btnText, .3, { x:desPosx, alpha:100 } );
			
			TweenLite.to(btnColor, .3, { x:desPosx, alpha:100 } );
			
		//	TweenLite.to(btnInfo, .3, { x:desPosx,alpha:100 } );
		}
		
		private function moveElementsBack()
		{
			var desPosx:int = stage.stageWidth*.5;
			var desPosy:int = stage.stageHeight * .5;
			TweenLite.to(mc_label, .3, { x:desPosx, y:desPosy } );
			
			var checkPosx:int = desPosx + m_gap_check.x;
			var checkPosy:int = desPosy + m_gap_check.y;
			TweenLite.to(btn_check, .3, { x:checkPosx, y:checkPosy } );
			
			btnExport.mouseEnabled = false;
			btnExport.alpha = 100;
			var exportPosx:int = desPosx + m_gap_print.x;
			var exportPosy:int = desPosy + m_gap_print.y;
			TweenLite.to(btnExport, .3, { x:exportPosx,y:exportPosy,alpha:0} );
			
			btnText.mouseEnabled = false;
			btnText.alpha = 100;
			var textPosx:int = desPosx + m_gap_text.x;
			var textPosy:int = desPosy + m_gap_text.y;
			TweenLite.to(btnText, .3, { x:textPosx, y:textPosy, alpha:0 } );
			
			btnColor.mouseEnabled = false;
			var colorPosx:int = desPosx + m_gap_color.x;
			var colorPosy:int = desPosy + m_gap_color.y;
			TweenLite.to(btnColor, .3, { x:colorPosx, y:colorPosy, alpha:0 } );
			
		/*	btnInfo.mouseEnabled = false;
			var infoPosx:int = desPosx + m_gap_info.x;
			var infoPosy:int = desPosy + m_gap_info.y;
			TweenLite.to(btnInfo, .3, { x:infoPosx, y:infoPosy, alpha:0 } );*/
		}
		
		private function showSavePicMC()
		{
			mc_savePic.alpha = 1;
			mc_savePic.y = 100;
			mc_savePic.x = stage.stageWidth / 2;
			mc_savePic.visible = true;
			
			mc_savePic.gotoAndPlay(1);
		}
	
	}
	
	
	
	
}

