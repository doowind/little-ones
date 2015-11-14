package  {
	
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	
	
	public class LableMC extends MovieClip {
		
		
		public function LableMC() {
			// constructor code
		}
		
		public function setLabel(str:String)
		{
			this.mc.label.text = str;
		}
		
		public function setColor(color:uint)
		{
			var mytf:TextFormat=new TextFormat();
		//	mytf.size = 20;
			mytf.color = color;
			this.mc.label..setTextFormat(mytf);
		}
	}
	
}
