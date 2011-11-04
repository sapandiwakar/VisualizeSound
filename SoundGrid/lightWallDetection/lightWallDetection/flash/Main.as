package{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.DataEvent;
	import flash.events.IOErrorEvent;
	import flash.net.XMLSocket;
	import flashx.textLayout.formats.Float;
	import caurina.transitions.Tweener;

	
	
	public class Main extends Sprite
	{
		private var 	centerBlobX;
		private var  	centerBlobY;
		private var		widthBlob;
		private var		heightBlob;
		private var		blobDetection:String;
		private var		blobDetectionLast:String="false";
		private var 	circleGrid:Array;
		private var 	ROWS:int=5;
		private var 	COLUMNS:int=5;
		private var 	H:int=stage.stageHeight;
		private var 	W:int=stage.stageWidth;
		
		public var serialServer:XMLSocket;
			
		public function Main() {
			
			var soundUrls = new Array();
			soundUrls[0] = ["Test.mp3","Test1.mp3","Test2.mp3","Test3.mp3","Test4.mp3"];
			soundUrls[1] = ["Test1.mp3","Test2.mp3","Test3.mp3","Test4.mp3","Test5.mp3"];
			soundUrls[2] = ["Test.mp3","Test1.mp3","Test2.mp3","Test3.mp3","Test4.mp3"];
			soundUrls[3] = ["Test1.mp3","Test2.mp3","Test3.mp3","Test4.mp3","Test5.mp3"];
			soundUrls[4] = ["Test.mp3","Test1.mp3","Test2.mp3","Test3.mp3","Test4.mp3"];
			
			circleGrid = new Array(ROWS);
			for ( var i:int = 0; i < ROWS; i++ )
			{
				var tempRow:Array = new Array(COLUMNS);
    			for ( var j:int = 0; j < COLUMNS; j++ )
    			{
        			tempRow[j] = new Circle(H*(i+1)/(ROWS+1), W*(j+1)/(COLUMNS+1),soundUrls[i][j]);
					addChild(tempRow[j]);
    			} 
				circleGrid[i] = tempRow;
			}
			
			
			serialServer=new XMLSocket  ;
			serialServer.connect("127.0.0.1",9001);
 
			serialServer.addEventListener(DataEvent.DATA,onReceiveData);
			serialServer.addEventListener(Event.CONNECT,onServer);
			serialServer.addEventListener(Event.CLOSE,onServer);
			serialServer.addEventListener(IOErrorEvent.IO_ERROR,onServer);

			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			//circleGrid[0][0].drawSong();
			
		}
		
		function enterFrame(e:Event):void
		{
			
			for ( var k:int = 0; k < ROWS; k++ ) {
    			for ( var l:int = 0; l < COLUMNS; l++ ) {
					circleGrid[k][l].drawSong();
				}
			}
			
			//if(blobDetection!=blobDetectionLast){
				if(blobDetection=="true"){
					
					var sh = height;
					var sw = width;
					var bcx:int = centerBlobX*W/640;
					var bcy:int = centerBlobY*H/480;
					var bw:int = widthBlob*W/640;
					var bh:int = heightBlob*H/480;
					
					trace(sh, sw, bcx, bcy, bw, bh);
					
					var r = (heightBlob+widthBlob)/2;
					
					for ( var i:int = 0; i < ROWS; i++ )
					{
    					for ( var j:int = 0; j < COLUMNS; j++ )
    					{
							var xCor = circleGrid[i][j].getXCor();
							var yCor = circleGrid[i][j].getYCor();
							
							if (xCor > bcx-bw/2 && xCor < bcx+bw/2 && yCor > bcy-bw/2 && yCor < bcy+bw/2) {
								var a:int = 12312;
								circleGrid[i][j].playSound(1);
								circleGrid[i][j].displayBright();
							} else {
								circleGrid[i][j].muteSound();
								circleGrid[i][j].displayDark();
							}
							//var checkSound = (circleGrid[i][j].getXCor()circleGrid[i][j].getXCor()-centerBlobX)*(circleGrid[i][j].getXCor()-centerBlobX) +
											//(circleGrid[i][j].getYCor()-centerBlobY)*(circleGrid[i][j].getYCor()-centerBlobY) - r*r;
							//trace(checkSound);
        					//if ( checkSound < 0) {
								//circleGrid[i][j].drawSong();
							//}
    					} 
					}
					
					Tweener.addTween(lightMc, {alpha:1, time:.1, transition:"linear"});
					Tweener.addTween(lightMc, {x:bcx, y:bcy, scaleX:bw/100, scaleY:bw/100, time:0, transition:"linear"});

				}else if(blobDetection=="false"){
					Tweener.addTween(lightMc, {alpha:0, time:.1, transition:"linear"});
				}
			//}
			
			//blobWidth=((centerBlobX*1024)/480)/1024
			Tweener.addTween(lightMc, {x:(centerBlobX*1024)/640, y:(centerBlobY*768)/480, scaleX:((heightBlob*768)/480)/100, scaleY:((heightBlob*768)/480)/100, time:.1, transition:"linear"});
			blobDetectionLast=blobDetection;
			
		}
		
		public function onServer(event:Event):void {
		}
		public function onReceiveData(dataEvent:DataEvent):void {
 
			var Data:DataEvent=dataEvent;
			//trace(Data);
 
			// This grabs the data from Data var which is the string passed
			// from our processing server.
			var test=Data.data;
			//trace(test);
 
			// This splits the variables we are passing.
			var parts:Array=test.split(",");
			
			trace(parts);
			
			blobDetection=parts[0];
			centerBlobX=parts[1];
			centerBlobY=parts[2];
			widthBlob=parts[3];
			heightBlob=parts[4];
		}

	}
	
}
