package nut.core
{
	public interface IAsset
	{
		function get type():uint;
		
		function get name():String;
		
		function set name(val:String):void;
		
		function set onLoaded(val:Function):void;
	}
}