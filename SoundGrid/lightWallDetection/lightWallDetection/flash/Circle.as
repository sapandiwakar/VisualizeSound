﻿package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.media.*;
    import flash.net.URLRequest;
    
    import org.libspark.betweenas3.BetweenAS3;
    import flashx.textLayout.formats.Float;
    
   // [SWF(width="500", height="500", backgroundColor="0", frameRate="60")]
    public class Circle extends Sprite
    {
        private var ch:SoundChannel;
        public static const colorAry:Array = [16711680,16712704,16713728,16715008,16716032,16717056,16718080,16719360,16720384,16721408,16722432,16723712,16724736,16725760,16727040,16728064,16729088,16730112,16731392,16732416,16733440,16734464,16735744,16736768,16737792,16738816,16740096,16741120,16742144,16743168,16744448,16745472,16746496,16747520,16748800,16749824,16750848,16751872,16753152,16754176,16755200,16756224,16757504,16758528,16759552,16760576,16761856,16762880,16763904,16764928,16766208,16767232,16768256,16769280,16770560,16771584,16772608,16773632,16774912,16775936,16776960,16514816,16187136,15924992,15662848,15400704,15073024,14810880,14548736,14286592,13958912,13696768,13434624,13172480,12844800,12582656,12320512,12058368,11796224,11468544,11206400,10944256,10682112,10354432,10092288,9830144,9568000,9240320,8978176,8716032,8453888,8126208,7864064,7601920,7339776,7012096,6749952,6487808,6225664,5897984,5635840,5373696,5111552,4783872,4521728,4259584,3997440,3669760,3407616,3145472,2883328,2555648,2293504,2031360,1769216,1441536,1179392,917248,655104,327424,65280,65284,65288,65293,65297,65301,65306,65310,65314,65318,65322,65327,65331,65335,65340,65344,65348,65352,65356,65361,65365,65369,65374,65378,65382,65386,65390,65395,65399,65403,65408,65412,65416,65420,65425,65429,65433,65437,65442,65446,65450,65454,65459,65463,65467,65471,65475,65480,65484,65488,65493,65497,65501,65505,65509,65514,65518,65522,65527,65531,65535,64511,63487,62207,61183,60159,58879,57855,56831,55807,54783,53503,52479,51455,50175,49151,48127,47103,46079,44799,43775,42751,41727,40447,39423,38399,37375,36095,35071,34047,33023,31743,30719,29695,28415,27391,26367,25343,24319,23039,22015,20991,19711,18687,17663,16639,15615,14335,13311,12287,11007,9983,8959,7935,6911,5631,4607,3583,2303,1279,255,262399,524543,852223,1114367,1376511,1638655,1966335,2228479,2490623,2818303,3080447,3342591,3604735,3932415,4194559,4456703,4718847,4980991,5308671,5570815,5832959,6095103,6422783,6684927,6947071,7274751,7536895,7799039,8061183,8388863,8651007,8913151,9175295,9437439,9765119,10027263,10289407,10617087,10879231,11141375,11403519,11731199,11993343,12255487,12517631,12779775,13107455,13369599,13631743,13893887,14221567,14483711,14745855,15073535,15335679,15597823,15859967,16187647,16449791,16711935,16711931,16711927,16711922,16711918,16711914,16711910,16711905,16711901,16711897,16711892,16711888,16711884,16711880,16711875,16711871,16711867,16711863,16711859,16711854,16711850,16711846,16711842,16711837,16711833,16711829,16711824,16711820,16711816,16711812,16711808,16711803,16711799,16711795,16711791,16711786,16711782,16711778,16711773,16711769,16711765,16711761,16711756,16711752,16711748,16711744,16711740,16711735,16711731,16711727,16711723,16711718,16711714,16711710,16711705,16711701,16711697,16711693,16711688,16711684];
        
        private var N:int = 12, index:int = 0;
        private var vertexList:Vector.<Point> = new Vector.<Point>();
        private var canvas:Sprite = new Sprite();
        private var snd:Sound;
		private var xCor:int;
		private var yCor:int;
		private var songURL:String = "test.MP3";
		public var soundLoaded:Boolean = false;
		private var volumeController:SoundTransform = new SoundTransform();
        
        public function Circle(xc:int, yc:int, url:String)
        {
			this.xCor = xc;
			this.yCor = yc;
			x = xc;
			y = yc;
			scaleX = .2;
			scaleY = .2;
			alpha = .1;
			
            graphics.beginFill(0); graphics.drawRect(0,0,500,500); graphics.endFill();
            addChild(canvas);
            canvas.x = xCor;
			canvas.y = yCor ;
            
            for(var i:int = 0; i < N; i++){
                var p:Point = new Point(Math.cos(2*Math.PI/N*i)*150, Math.sin(2*Math.PI/N*i)*150);
                vertexList[i] = p;
            }
			
			songURL = url;
			
			snd = new Sound();
            snd.load(new URLRequest(songURL));
            snd.addEventListener(Event.COMPLETE, onComplete);
			volumeController.volume = 0;
        }

		public function playSound(v:Number):void{
			volumeController.volume = v;
			ch.soundTransform = volumeController;
		}
		
		public function muteSound():void{
			volumeController.volume = 0;
			ch.soundTransform = volumeController;
		}
		
		public function displayBright():void {
			alpha = 1;
		}
		
		public function displayDark():void {
			alpha = .1;
		}
		
        private function onComplete(e:Event):void{
			soundLoaded = true;
			ch = snd.play(0,1000);
			ch.soundTransform = volumeController;
			drawSong();
            
            //addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
     /*   private function onEnterFrame(e:Event):void{
			
            var tx:Number = vertexList[index].x, ty:Number = vertexList[index].y;
            var size:Number = Math.sqrt(tx*tx+ty*ty);
            var peak:Number = ch.rightPeak*ch.leftPeak;
            tx /= size;
            ty /= size;
            tx *= peak*250+50;
            ty *= peak*250+50;
            BetweenAS3.to(vertexList[index], {x:tx, y:ty}, 0.2).play();
            
            index++;
            index %= N;
            
            canvas.graphics.clear();
            canvas.graphics.lineStyle(5, 0xFFFFFF);
            canvas.graphics.moveTo((vertexList[N-1].x+vertexList[0].x)*0.5, (vertexList[N-1].y+vertexList[0].y)*0.5);
            for(var i:int = 0; i < N-1; i++){
                var p1:Point = vertexList[i], p2:Point = vertexList[(i+1)%N];
                var p3:Point = new Point((p1.x+p2.x)*0.5, (p1.y+p2.y)*0.5);
                canvas.graphics.curveTo(p1.x, p1.y, p3.x, p3.y);
            }
            canvas.graphics.curveTo(vertexList[N-1].x, vertexList[N-1].y, (vertexList[N-1].x+vertexList[0].x)*0.5, (vertexList[N-1].y+vertexList[0].y)*0.5);
        }*/
		
		public function drawSong():void{
			if (!soundLoaded) {
				return;
			}
			var tx:Number = vertexList[index].x, ty:Number = vertexList[index].y;
            var size:Number = Math.sqrt(tx*tx+ty*ty);
            var peak:Number = ch.rightPeak*ch.leftPeak;
            tx /= size;
            ty /= size;
            tx *= peak*250+50;
            ty *= peak*250+50;
            BetweenAS3.to(vertexList[index], {x:tx, y:ty}, 0.2).play();
            
            index++;
            index %= N;
            
            canvas.graphics.clear();
            canvas.graphics.lineStyle(5, 0xFFFFFF);
            canvas.graphics.moveTo((vertexList[N-1].x+vertexList[0].x)*0.5, (vertexList[N-1].y+vertexList[0].y)*0.5);
            for(var i:int = 0; i < N-1; i++){
                var p1:Point = vertexList[i], p2:Point = vertexList[(i+1)%N];
                var p3:Point = new Point((p1.x+p2.x)*0.5, (p1.y+p2.y)*0.5);
                canvas.graphics.curveTo(p1.x, p1.y, p3.x, p3.y);
            }
            canvas.graphics.curveTo(vertexList[N-1].x, vertexList[N-1].y, (vertexList[N-1].x+vertexList[0].x)*0.5, (vertexList[N-1].y+vertexList[0].y)*0.5);
			//playSound();
		}
		
		public function getXCor():int{
			return xCor;
		}
		
		public function getYCor():int{
			return yCor;
		}
    }
}