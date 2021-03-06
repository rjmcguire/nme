// Might have waxe without NME
#if nme
import nme.Assets;
#elseif waxe
import wx.Assets;
#end

#if cpp
::foreach ndlls::::importStatic::::end::
#end



#if iosview
@:buildXml("
<files id='__lib__'>
  <file name='FrameworkInterface.mm'>
  </file>
</files>
")
#end
@:cppFileCode("
::foreach ndlls:: ::if (registerPrim!=null):: extern \"C\" int ::registerPrim::();
::end::::end::
")
class ApplicationMain
{
   static public var engines : Array<Dynamic> = [
      ::foreach ENGINES:: { name: "::name::", version:"::version::" }, ::end::
   ];


   #if waxe
   static public var frame : wx.Frame;
   static public var autoShowFrame : Bool = true;
   #if nme
   static public var nmeStage : wx.NMEStage;
   #end
   #end

   
   public static var winWidth:Float = ::WIN_WIDTH::;
   public static var winHeight:Float = ::WIN_HEIGHT::;
   public static var winBackground:Int = ::WIN_BACKGROUND::;
   public static var onLoaded:Void->Void;

   
   public static function main()
   {
      #if cpp
      ::if MEGATRACE::
      untyped __global__.__hxcpp_execution_trace(2);
      ::end::
      #end


      #if flash

      nme.AssetData.create();

      #elseif nme

      ::if REDIRECT_TRACE::
      nme.Lib.redirectTrace();
      ::end::

      nme.app.Application.setPackage("::APP_COMPANY::", "::APP_FILE::", "::APP_PACKAGE::", "::APP_VERSION::");
      nme.text.Font.useNative = ::NATIVE_FONTS::;

      nme.AssetData.create();

      ::if (sslCaCert != "")::
      nme.net.URLLoader.initialize(nme.installer.Assets.getResourceName("::sslCaCert::"));
      ::end::

      #if (cpp||neko)
         nme.app.Application.setFixedOrientation(
            ::if (WIN_ORIENTATION == "portrait")::
               nme.app.Application.OrientationPortraitAny
            ::elseif (WIN_ORIENTATION == "landscape")::
               nme.app.Application.OrientationLandscapeAny
            ::else::
               nme.app.Application.OrientationAny
             ::end::
        );
      #end

      #end
   

   
      #if flash
      flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
      flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;

      var load = function() ApplicationBoot.createInstance();

      ::if (PRELOADER_NAME!=null)::
         onLoaded = load;
         var preloader = new ::PRELOADER_NAME::();
         preloader.onInit();
         
      ::else::
         load();
      ::end::


      #elseif waxe

      #if nme
      nme.display.ManagedStage.initSdlAudio();
      #end

      if (ApplicationBoot.canCallMain())
         ApplicationBoot.createInstance();
      else
      {
         wx.App.boot(function()
         {
            var size = { width: ::WIN_WIDTH::, height: ::WIN_HEIGHT:: };
            ::if (APP_FRAME != null)::
               frame = wx.::APP_FRAME::.create(null, null, "::APP_TITLE::", null, size);
            ::else::
               frame = wx.Frame.create(null, null, "::APP_TITLE::", null, size);
            ::end::

            #if nme
               wx.NMEStage.create(frame, null, null,
               {
                  width: ::WIN_WIDTH::,
                  height: ::WIN_HEIGHT::,
                  fullscreen: ::WIN_FULLSCREEN::,
                  stencilBuffer: ::WIN_STENCIL_BUFFER::,
                  depthBuffer: ::WIN_DEPTH_BUFFER::,
                  antiAliasing: ::WIN_ANTIALIASING::,
                  resizable: ::WIN_RESIZABLE::,
                  vsync: ::WIN_VSYNC::,
                  fps : ::WIN_FPS:: * 1.0,
                  color : ::WIN_BACKGROUND::,
                  title : "::APP_TITLE::",
                  icon  : Assets.info.get("::WIN_ICON::")==null ? null : getAsset("::WIN_ICON::")
               });

               // Show frame before creating instance so context is good.
               frame.shown = true;
               ApplicationBoot.createInstance();
               wx.App.setTopWindow(frame);
   
            #else
               ApplicationBoot.createInstance();
               if (autoShowFrame)
               {
                  wx.App.setTopWindow(frame);
                  frame.shown = true;
               }
            #end

        });
      }
      #elseif cppia
       ApplicationBoot.createInstance();
      #else
         var flags:Int = 
            (::WIN_HARDWARE:: ? nme.app.Application.HARDWARE : 0) |
            (::WIN_DEPTH_BUFFER:: ? nme.app.Application.DEPTH_BUFFER : 0) |
            (::WIN_STENCIL_BUFFER:: ? nme.app.Application.STENCIL_BUFFER : 0) |
            (::WIN_RESIZABLE:: ? nme.app.Application.RESIZABLE : 0) |
            (::WIN_BORDERLESS:: ? nme.app.Application.BORDERLESS : 0) |
            (::WIN_VSYNC:: ? nme.app.Application.VSYNC : 0) |
            (::WIN_FULLSCREEN:: ? nme.app.Application.FULLSCREEN : 0) |
            (::WIN_ANTIALIASING:: == 4 ? nme.app.Application.HW_AA_HIRES : 0) |
            (::WIN_ANTIALIASING:: == 2 ? nme.app.Application.HW_AA : 0);


         #if nme_application

            var params = { flags : flags,
               fps : ::WIN_FPS:: * 1.0,
               color : ::WIN_BACKGROUND::,
               width : ::WIN_WIDTH::,
               height : ::WIN_HEIGHT::,
               title : "::APP_TITLE::",
               icon  : Assets.info.get("::WIN_ICON::")==null ? null : getAsset("::WIN_ICON::")
            };

            nme.app.Application.createWindow(function(window:nme.app.Window) {
               new ::APP_MAIN::(window);
            }, params );

         #else

            nme.Lib.create(function() { 
                  nme.Lib.current.stage.align = nme.display.StageAlign.TOP_LEFT;
                  nme.Lib.current.stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
                  nme.Lib.current.loaderInfo = nme.display.LoaderInfo.create (null);
                  ApplicationBoot.createInstance();
               },
               ::WIN_WIDTH::, ::WIN_HEIGHT::, 
               ::WIN_FPS::, 
               ::WIN_BACKGROUND::,
               flags,
               "::APP_TITLE::"
               ::if (WIN_ICON!=null)::
               , getAsset("::WIN_ICON::")
               ::end::
            );

         #end
      #end
   }

   @:keep function keepMe() return Reflect.callMethod;

   public static function setAndroidViewHaxeObject(inObj:Dynamic)
   {
      #if androidview
      try
      {
         var setHaxeObject = nme.JNI.createStaticMethod("::CLASS_PACKAGE::.::CLASS_NAME::Base",
              "setHaxeCallbackObject", "(Lorg/haxe/nme/HaxeObject;)V", true, true );
         if (setHaxeObject!=null)
            setHaxeObject([inObj]);
      }
      catch(e:Dynamic) {  }
      #end
   }

   public static function getAsset(inName:String) : Dynamic
   {
      var i = Assets.info.get(inName);
      if (i==null)
         throw "Asset does not exist: " + inName;
      var cached = i.getCache();
      if (cached!=null)
         return cached;
      switch(i.type)
      {
         case BINARY, TEXT, SWF: return Assets.getBytes(inName);
         case FONT: return Assets.getFont(inName);
         case IMAGE: return Assets.getBitmapData(inName);
         case MUSIC, SOUND: return Assets.getSound(inName);
         case MOVIE_CLIP: return null;
      }

      throw "Unknown asset type: " + i.type;
      return null;
   }
   
   
   public static function __init__ ()
   {
      #if neko
      untyped $loader.path = $array ("@executable_path/", $loader.path);
      #elseif cpp
      ::foreach ndlls:: ::if (registerPrim!=null):: untyped __cpp__("::registerPrim::()");
::end:: ::end::
      #end
   }
   
   
}

