package com.example.godotmyket;

import android.util.Log;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import java.util.HashSet;
import java.util.Set;

import ir.myket.billingclient.IabHelper;
import ir.myket.billingclient.util.IabResult;

public class GodotMyket extends GodotPlugin {
    private IabHelper mHelper;
    private String TAG = "godot";

    /**
     * Base constructor passing a {@link Godot} instance through which the plugin can access Godot's
     * APIs and lifecycle events.
     *
     * @param godot
     */
    public GodotMyket(Godot godot) {
        super(godot);
    }

    @Override
    public String getPluginName() {
        return "GodotMyket";
    }

    @Override
    public Set<SignalInfo> getPluginSignals() {
        Set<SignalInfo> signals = new HashSet<>();
        signals.add(new SignalInfo("connection_succeed"));
        signals.add(new SignalInfo("connection_failed", String.class));
        return signals;
    }

    @UsedByGodot
    public void connect_to_myket(String public_key) {
        mHelper = new IabHelper(getActivity(), public_key);
        mHelper.startSetup(new IabHelper.OnIabSetupFinishedListener() {
            @Override
            public void onIabSetupFinished(IabResult result) {
                if (mHelper == null) return;
                if (result.isSuccess()) {
                    emitSignal("connection_succeed");
                }
                else if (result.isFailure()) {
                    emitSignal("connection_failed", result.getMessage());
                }
            }
        });
    }
}
