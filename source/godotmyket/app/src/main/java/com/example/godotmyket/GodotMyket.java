package com.example.godotmyket;

import android.content.Intent;
import android.net.Uri;

import org.godotengine.godot.Dictionary;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import java.util.Set;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.atomic.AtomicReference;

import ir.myket.billingclient.IabHelper;
import ir.myket.billingclient.util.IabResult;
import ir.myket.billingclient.util.Inventory;
import ir.myket.billingclient.util.Purchase;
import ir.myket.billingclient.util.SkuDetails;

public class GodotMyket extends GodotPlugin {
    private final AtomicReference<IabHelper> mHelper = new AtomicReference<>();

    public GodotMyket(Godot godot) {
        super(godot);
    }

    @Override
    public String getPluginName() {
        return "GodotMyket";
    }

    @Override
    public Set<SignalInfo> getPluginSignals() {
        return Set.of(
            new SignalInfo("connection_succeed"),
            new SignalInfo("connection_failed", String.class),
            new SignalInfo("query_inventory_finished", Boolean.class, String.class, Dictionary.class),
            new SignalInfo("query_inventory_failed", String.class),
            new SignalInfo("iab_purchase_finished", Boolean.class, String.class, Dictionary.class),
            new SignalInfo("iab_purchase_failed", String.class),
            new SignalInfo("consume_finished", Boolean.class, String.class, Dictionary.class),
            new SignalInfo("consume_failed", String.class)
        );
    }

    private Dictionary createPurchaseDictionary(Purchase info) {
        var purchase = new Dictionary();
        purchase.put("order_id", info.getOrderId());
        purchase.put("item_type", info.getItemType());
        purchase.put("sku", info.getSku());
        purchase.put("purchase_time", info.getPurchaseTime());
        purchase.put("purchase_state", info.getPurchaseState());
        purchase.put("developer_payload", info.getDeveloperPayload());
        purchase.put("token", info.getToken());
        purchase.put("original_json", info.getOriginalJson());
        purchase.put("package_name", info.getPackageName());
        purchase.put("signature", info.getSignature());
        return purchase;
    }

    private void showIntent(String url) {
        var intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        getActivity().startActivity(intent);
    }

    @UsedByGodot
    public void connect_to_myket(String public_key) {
        var helper = new IabHelper(getActivity(), public_key);
        mHelper.set(helper);
        
        helper.startSetup(result -> {
            if (mHelper.get() == null) return;
            emitSignal(result.isSuccess() ? "connection_succeed" : 
                      "connection_failed", result.getMessage());
        });
    }

    @UsedByGodot
    public void query_inventory_async(boolean query_sku_details, String[] item_skus) {
        getGodot().runOnUiThread(() -> {
            try {
                var helper = mHelper.get();
                if (helper == null) return;

                helper.queryInventoryAsync(query_sku_details, List.of(item_skus), 
                    (result, inv) -> {
                        if (mHelper.get() == null) return;
                        
                        var inventory = new Dictionary();
                        var products = new Dictionary();
                        var purchases = new Dictionary();

                        inv.getAllProducts().forEach(item -> {
                            var product = new Dictionary();
                            product.put("sku", item.getSku());
                            product.put("type", item.getType());
                            product.put("price", item.getPrice());
                            product.put("title", item.getTitle());
                            product.put("description", item.getDescription());
                            products.put(item.getSku(), product);
                        });

                        inv.getAllPurchases().forEach(item -> 
                            purchases.put(item.getOrderId(), createPurchaseDictionary(item)));

                        inventory.put("products", products);
                        inventory.put("purchases", purchases);
                        emitSignal("query_inventory_finished", result.isSuccess(), 
                                 result.getMessage(), inventory);
                    });
            } catch (Exception e) {
                emitSignal("query_inventory_failed", 
                          "Error querying inventory. Another async operation in progress.");
            }
        });
    }

    @UsedByGodot
    public void launch_purchase_flow(String sku, String payload) {
        try {
            var helper = mHelper.get();
            if (helper == null) return;

            helper.launchPurchaseFlow(getActivity(), sku, 
                (result, info) -> {
                    if (mHelper.get() == null) return;
                    var purchase = result.isSuccess() ? createPurchaseDictionary(info) : 
                                                      new Dictionary();
                    emitSignal("iab_purchase_finished", result.isSuccess(), 
                             result.getMessage(), purchase);
                }, payload);
        } catch (Exception e) {
            emitSignal("iab_purchase_failed", 
                      "Error launching purchase flow. Another async operation in progress.");
        }
    }

    @UsedByGodot
    public void consume_async(Dictionary purchase) {
        getGodot().runOnUiThread(() -> {
            try {
                var helper = mHelper.get();
                if (helper == null) return;

                var itemType = (String) purchase.get("item_type");
                var json = (String) purchase.get("original_json");
                var signature = (String) purchase.get("signature");
                var purchaseObj = new Purchase(itemType, json, signature);

                helper.consumeAsync(purchaseObj, (info, result) -> {
                    if (mHelper.get() == null) return;
                    var purchaseDict = result.isSuccess() ? createPurchaseDictionary(info) : 
                                                          new Dictionary();
                    emitSignal("consume_finished", result.isSuccess(), 
                             result.getMessage(), purchaseDict);
                });
            } catch (Exception e) {
                emitSignal("consume_failed", 
                          "Error consuming. Another async operation in progress.");
            }
        });
    }

    @UsedByGodot
    public void disconnect_from_myket() {
        var helper = mHelper.get();
        if (helper != null) {
            helper.dispose();
            mHelper.set(null);
        }
    }

    @UsedByGodot
    public void show_intent_comment(String package_name) {
        showIntent("myket://comment?id=" + 
                  (package_name.isEmpty() ? getActivity().getPackageName() : package_name));
    }

    @UsedByGodot
    public void show_intent_details(String package_name) {
        showIntent("myket://details?id=" + 
                  (package_name.isEmpty() ? getActivity().getPackageName() : package_name));
    }

    @UsedByGodot
    public void show_intent_download(String package_name) {
        showIntent("myket://download?id=" + 
                  (package_name.isEmpty() ? getActivity().getPackageName() : package_name));
    }

    @UsedByGodot
    public void show_intent_developer(String package_name) {
        showIntent("myket://developer/" + 
                  (package_name.isEmpty() ? getActivity().getPackageName() : package_name));
    }
}
