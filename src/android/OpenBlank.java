package org.apache.cordova.openblank;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.net.Uri;
import android.provider.Browser;
import android.util.Log;
import org.apache.cordova.CordovaPlugin;


@SuppressLint("SetJavaScriptEnabled")
public class OpenBlank extends CordovaPlugin {
    @Override
    public boolean onOverrideUrlLoading(String url) {
        Log.d("OpenBlank", "onOverrideUrlLoading called with URL " + url);
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW);
            // Omitting the MIME type for file: URLs causes "No Activity found to handle Intent".
            // Adding the MIME type to http: URLs causes them to not be handled by the downloader.
            Uri uri = Uri.parse(url);
            if ("http".equals(uri.getScheme()) || "https".equals(uri.getScheme())) {
                webView.sendJavascript("cordova.InAppBrowser.open('" + url + "', '_blank');");
            } else {
                return false;
            }
            return true; // true prevents navigation navigation
        } catch (android.content.ActivityNotFoundException e) {
            Log.d("OpenBlank", "OpenBlank: Error loading url " + url + ":" + e.toString());
            return false;
        }
    }
}
