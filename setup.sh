#!/bin/bash
set -e
J=src/main/java/com/abdou/easybuild
mkdir -p $J/client src/main/resources/META-INF src/main/resources/assets/easybuild/lang .github/workflows

echo 'iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAYAAABccqhmAAADP0lEQVR4nO3WMRHCABREQRIHeEANQxFBCEpDS0+NqETGn8zbVXDVm1tej/tx47L+n+/0BC5snR4AzBEACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACFvW/XdMj6Dr+d6mJ6R5ABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABB2AlYoCS33/yfNAAAAAElFTkSuQmCC' | base64 -d > src/main/resources/logo.png

cat > settings.gradle <<'EOF'
pluginManagement {
    repositories {
        gradlePluginPortal()
        maven { name = 'MinecraftForge'; url = 'https://maven.minecraftforge.net/' }
    }
}
rootProject.name = 'easybuild'
EOF

cat > gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx3G
org.gradle.daemon=false
EOF

cat > build.gradle <<'EOF'
plugins {
    id 'eclipse'
    id 'net.minecraftforge.gradle' version '[6.0.16,6.2)'
}

version = '1.2.2'
group = 'com.abdou.easybuild'
base { archivesName = 'easy_build_without_items-forge-1.20.1' }

java.toolchain.languageVersion = JavaLanguageVersion.of(17)

minecraft {
    mappings channel: 'official', version: '1.20.1'
    runs {
        client {
            workingDirectory project.file('run')
            mods { easybuild { source sourceSets.main } }
        }
        server {
            workingDirectory project.file('run')
            mods { easybuild { source sourceSets.main } }
        }
    }
}

dependencies {
    minecraft 'net.minecraftforge:forge:1.20.1-47.3.0'
}

tasks.named('jar', Jar).configure {
    manifest {
        attributes(['Specification-Title': 'easybuild', 'Implementation-Version': project.version])
    }
    finalizedBy 'reobfJar'
}

tasks.withType(JavaCompile).configureEach { options.encoding = 'UTF-8' }
EOF

cat > .github/workflows/build.yml <<'EOF'
name: Build mod jar
on: [push, workflow_dispatch]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'
      - uses: gradle/actions/setup-gradle@v3
        with:
          gradle-version: '8.1.1'
      - run: gradle build --no-daemon
      - uses: actions/upload-artifact@v4
        with:
          name: easybuild-forge-jar
          path: build/libs/*.jar
EOF

cat > src/main/resources/META-INF/mods.toml <<'EOF'
modLoader="javafml"
loaderVersion="[47,)"
license="All Rights Reserved"

[[mods]]
modId="easybuild"
version="1.2.2"
displayName="Easy build without items"
authors="Abdou"
logoFile="logo.png"
description='''Effortless Building without items. Ctrl+S = build mode on/off, B = menu. Line, wall, roof, filled box, mirror, repeat, undo, live preview.'''

[[dependencies.easybuild]]
    modId="forge"
    mandatory=true
    versionRange="[47,)"
    ordering="NONE"
    side="BOTH"

[[dependencies.easybuild]]
    modId="minecraft"
    mandatory=true
    versionRange="[1.20.1,1.21)"
    ordering="NONE"
    side="BOTH"
EOF

cat > src/main/resources/pack.mcmeta <<'EOF'
{ "pack": { "description": "Easy build resources", "pack_format": 15 } }
EOF

cat > src/main/resources/assets/easybuild/lang/en_us.json <<'EOF'
{
  "key.categories.easybuild": "Easy build",
  "key.easybuild.menu": "Open Easy build menu",
  "key.easybuild.toggle": "Build mode on/off"
}
EOF

cat > $J/EasyBuild.java <<'EOF'
package com.abdou.easybuild;

import net.minecraftforge.common.MinecraftForge;
import net.minecraftforge.fml.common.Mod;

@Mod(EasyBuild.MODID)
public class EasyBuild {
    public static final String MODID = "easybuild";

    public EasyBuild() {
        Network.register();
        MinecraftForge.EVENT_BUS.register(BuildHandler.class);
    }
}
EOF

cat > $J/Network.java <<'EOF'
package com.abdou.easybuild;

import net.minecraft.resources.ResourceLocation;
import net.minecraft.server.level.ServerPlayer;
import net.minecraftforge.network.NetworkDirection;
import net.minecraftforge.network.NetworkRegistry;
import net.minecraftforge.network.PacketDistributor;
import net.minecraftforge.network.simple.SimpleChannel;

public class Network {
    private static final String VERSION = "2";
    public static final SimpleChannel CHANNEL = NetworkRegistry.newSimpleChannel(
            new ResourceLocation(EasyBuild.MODID, "main"), () -> VERSION, VERSION::equals, VERSION::equals);

    public static void register() {
        CHANNEL.messageBuilder(SettingsPacket.class, 0, NetworkDirection.PLAY_TO_SERVER)
                .encoder(SettingsPacket::encode)
                .decoder(SettingsPacket::new)
                .consumerMainThread(SettingsPacket::handle)
                .add();
        CHANNEL.messageBuilder(SyncPacket.class, 1, NetworkDirection.PLAY_TO_CLIENT)
                .encoder(SyncPacket::encode)
                .decoder(SyncPacket::new)
                .consumerMainThread(SyncPacket::handle)
                .add();
    }

    public static void sendTo(ServerPlayer player, Object msg) {
        CHANNEL.send(PacketDistributor.PLAYER.with(() -> player), msg);
    }
}
EOF

cat > $J/SettingsPacket.java <<'EOF'
package com.abdou.easybuild;

import net.minecraft.network.FriendlyByteBuf;
import net.minecraft.server.level.ServerPlayer;
import net.minecraftforge.network.NetworkEvent;

import java.util.function.Supplier;

public class SettingsPacket {
    public final boolean enabled, mx, mz, my, setCenter, undo;
    public final int mode, count, dx, dy, dz;

    public SettingsPacket(boolean enabled, int mode, boolean mx, boolean mz, boolean my, boolean setCenter,
                          int count, int dx, int dy, int dz, boolean undo) {
        this.enabled = enabled; this.mode = mode; this.mx = mx; this.mz = mz; this.my = my;
        this.setCenter = setCenter; this.count = count; this.dx = dx; this.dy = dy; this.dz = dz; this.undo = undo;
    }

    public SettingsPacket(FriendlyByteBuf b) {
        this(b.readBoolean(), b.readVarInt(), b.readBoolean(), b.readBoolean(), b.readBoolean(), b.readBoolean(),
                b.readVarInt(), b.readVarInt(), b.readVarInt(), b.readVarInt(), b.readBoolean());
    }

    public void encode(FriendlyByteBuf b) {
        b.writeBoolean(enabled); b.writeVarInt(mode); b.writeBoolean(mx); b.writeBoolean(mz); b.writeBoolean(my);
        b.writeBoolean(setCenter); b.writeVarInt(count); b.writeVarInt(dx); b.writeVarInt(dy); b.writeVarInt(dz);
        b.writeBoolean(undo);
    }

    public void handle(Supplier<NetworkEvent.Context> ctx) {
        ServerPlayer player = ctx.get().getSender();
        if (player != null) BuildHandler.applySettings(player, this);
    }
}
EOF

cat > $J/SyncPacket.java <<'EOF'
package com.abdou.easybuild;

import net.minecraft.core.BlockPos;
import net.minecraft.network.FriendlyByteBuf;
import net.minecraftforge.network.NetworkEvent;

import java.util.function.Supplier;

/** Server -> client: what the preview needs to know (build mode, first point, mirror center). */
public class SyncPacket {
    public final boolean enabled;
    public final BlockPos first, center;

    public SyncPacket(boolean enabled, BlockPos first, BlockPos center) {
        this.enabled = enabled; this.first = first; this.center = center;
    }

    public SyncPacket(FriendlyByteBuf b) {
        this.enabled = b.readBoolean();
        this.first = b.readBoolean() ? b.readBlockPos() : null;
        this.center = b.readBoolean() ? b.readBlockPos() : null;
    }

    public void encode(FriendlyByteBuf b) {
        b.writeBoolean(enabled);
        b.writeBoolean(first != null); if (first != null) b.writeBlockPos(first);
        b.writeBoolean(center != null); if (center != null) b.writeBlockPos(center);
    }

    public void handle(Supplier<NetworkEvent.Context> ctx) {
        ClientState.enabled = enabled;
        ClientState.first = first;
        ClientState.center = center;
    }
}
EOF

cat > $J/ClientState.java <<'EOF'
package com.abdou.easybuild;

import net.minecraft.core.BlockPos;

/** Client copy of the settings (plain data, safe on both sides). */
public final class ClientState {
    public static boolean enabled, mx, mz, my;
    public static int mode, count, dx, dy, dz;
    public static BlockPos first, center;

    static { reset(); }

    public static void reset() {
        enabled = false; mode = 1; mx = mz = my = false;
        count = 0; dx = 2; dy = 0; dz = 0;
        first = null; center = null;
    }

    public static SettingsPacket packet(boolean setCenter, boolean undo) {
        return new SettingsPacket(enabled, mode, mx, mz, my, setCenter, count, dx, dy, dz, undo);
    }
}
EOF

cat > $J/BuildState.java <<'EOF'
package com.abdou.easybuild;

import net.minecraft.core.BlockPos;
import net.minecraft.resources.ResourceKey;
import net.minecraft.world.item.Item;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.state.BlockState;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.List;

public class BuildState {
    public boolean enabled = false;
    public int mode = 1;
    public boolean mx, mz, my;
    public BlockPos center;
    public int count = 0, dx = 2, dy = 0, dz = 0;
    public BlockPos first;
    public ResourceKey<Level> firstDim;
    public final Deque<UndoEntry> undo = new ArrayDeque<>();

    public boolean anyMirror() { return mx || mz || my; }

    public record Rec(BlockPos pos, BlockState old) {}
    public record UndoEntry(ResourceKey<Level> dim, List<Rec> blocks, Item item, boolean refund) {}
}
EOF

cat > $J/Shapes.java <<'EOF'
package com.abdou.easybuild;

import net.minecraft.core.BlockPos;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/** Shape maths shared by the server (building) and the client (preview). */
public final class Shapes {
    public static final String[] MODES = {"Normal", "Line", "Wall", "Roof", "Filled Box"};
    public static final String[] MODES_AR = {"عادي", "خط", "جدار", "سقف", "صندوق ممتلئ"};
    public static final int MAX_BLOCKS = 4000;

    /** Returns null when the area is too large. */
    public static List<BlockPos> shape(int mode, BlockPos a, BlockPos b) {
        return switch (mode) {
            case 1 -> line(a, b);
            case 2 -> wall(a, b);
            case 3 -> roof(a, b);
            case 4 -> box(a, b);
            default -> List.of(b);
        };
    }

    public static List<BlockPos> line(BlockPos a, BlockPos b) {
        int dx = b.getX() - a.getX(), dy = b.getY() - a.getY(), dz = b.getZ() - a.getZ();
        int n = Math.max(Math.abs(dx), Math.max(Math.abs(dy), Math.abs(dz)));
        List<BlockPos> out = new ArrayList<>();
        for (int i = 0; i <= n; i++) {
            double t = n == 0 ? 0 : (double) i / n;
            out.add(new BlockPos((int) Math.round(a.getX() + dx * t),
                    (int) Math.round(a.getY() + dy * t), (int) Math.round(a.getZ() + dz * t)));
        }
        return out;
    }

    /** Vertical wall: line on the ground from a to b, raised from the lower to the higher point. */
    public static List<BlockPos> wall(BlockPos a, BlockPos b) {
        int dx = b.getX() - a.getX(), dz = b.getZ() - a.getZ();
        int n = Math.max(Math.abs(dx), Math.abs(dz));
        int y0 = Math.min(a.getY(), b.getY()), y1 = Math.max(a.getY(), b.getY());
        if ((long) (n + 1) * (y1 - y0 + 1) > MAX_BLOCKS) return null;
        Set<BlockPos> out = new LinkedHashSet<>();
        for (int i = 0; i <= n; i++) {
            double t = n == 0 ? 0 : (double) i / n;
            int x = (int) Math.round(a.getX() + dx * t), z = (int) Math.round(a.getZ() + dz * t);
            for (int y = y0; y <= y1; y++) out.add(new BlockPos(x, y, z));
        }
        return new ArrayList<>(out);
    }

    /** Flat roof/floor at the height of the first point. */
    public static List<BlockPos> roof(BlockPos a, BlockPos b) {
        int x0 = Math.min(a.getX(), b.getX()), x1 = Math.max(a.getX(), b.getX());
        int z0 = Math.min(a.getZ(), b.getZ()), z1 = Math.max(a.getZ(), b.getZ());
        if ((long) (x1 - x0 + 1) * (z1 - z0 + 1) > MAX_BLOCKS) return null;
        List<BlockPos> out = new ArrayList<>();
        for (int x = x0; x <= x1; x++)
            for (int z = z0; z <= z1; z++) out.add(new BlockPos(x, a.getY(), z));
        return out;
    }

    public static List<BlockPos> box(BlockPos a, BlockPos b) {
        int x0 = Math.min(a.getX(), b.getX()), x1 = Math.max(a.getX(), b.getX());
        int y0 = Math.min(a.getY(), b.getY()), y1 = Math.max(a.getY(), b.getY());
        int z0 = Math.min(a.getZ(), b.getZ()), z1 = Math.max(a.getZ(), b.getZ());
        if ((long) (x1 - x0 + 1) * (y1 - y0 + 1) * (z1 - z0 + 1) > MAX_BLOCKS) return null;
        List<BlockPos> out = new ArrayList<>();
        for (int x = x0; x <= x1; x++)
            for (int y = y0; y <= y1; y++)
                for (int z = z0; z <= z1; z++) out.add(new BlockPos(x, y, z));
        return out;
    }

    public static List<BlockPos> mirror(List<BlockPos> list, boolean mx, boolean mz, boolean my, BlockPos c) {
        if (!(mx || mz || my) || c == null) return list;
        Set<BlockPos> out = new LinkedHashSet<>();
        for (BlockPos p : list) {
            int[] xs = mx ? new int[]{p.getX(), 2 * c.getX() - p.getX()} : new int[]{p.getX()};
            int[] ys = my ? new int[]{p.getY(), 2 * c.getY() - p.getY()} : new int[]{p.getY()};
            int[] zs = mz ? new int[]{p.getZ(), 2 * c.getZ() - p.getZ()} : new int[]{p.getZ()};
            for (int x : xs) for (int y : ys) for (int z : zs) out.add(new BlockPos(x, y, z));
        }
        return new ArrayList<>(out);
    }

    public static List<BlockPos> repeat(List<BlockPos> list, int count, int dx, int dy, int dz) {
        if (count <= 0) return list;
        Set<BlockPos> out = new LinkedHashSet<>();
        for (BlockPos p : list) {
            out.add(p);
            for (int i = 1; i <= count; i++) out.add(p.offset(dx * i, dy * i, dz * i));
            if (out.size() > MAX_BLOCKS * 2) break;
        }
        return new ArrayList<>(out);
    }
}
EOF

cat > $J/BuildHandler.java <<'EOF'
package com.abdou.easybuild;

import net.minecraft.core.BlockPos;
import net.minecraft.network.chat.Component;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.util.Mth;
import net.minecraft.world.entity.player.Inventory;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraftforge.event.TickEvent;
import net.minecraftforge.event.entity.player.PlayerEvent;
import net.minecraftforge.event.level.BlockEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class BuildHandler {
    private static final int MAX_UNDO = 10;
    private static final Map<UUID, BuildState> STATES = new HashMap<>();
    private static final List<Pending> PENDING = new ArrayList<>();

    private record Pending(ServerPlayer player, ServerLevel level, BlockPos origin, BlockState state) {}

    public static BuildState get(Player p) {
        return STATES.computeIfAbsent(p.getUUID(), k -> new BuildState());
    }

    private static void bar(Player p, String en, String ar) {
        p.displayClientMessage(Component.literal(en + " §7| " + ar), true);
    }

    private static void sync(ServerPlayer p, BuildState s) {
        Network.sendTo(p, new SyncPacket(s.enabled, s.first, s.center));
    }

    @SubscribeEvent
    public static void onPlace(BlockEvent.EntityPlaceEvent e) {
        if (e instanceof BlockEvent.EntityMultiPlaceEvent) return; // doors, beds...
        if (!(e.getEntity() instanceof ServerPlayer player)) return;
        if (!(e.getLevel() instanceof ServerLevel level)) return;
        if (!get(player).enabled) return;
        // run after vanilla finished placing (so item counts stay correct)
        PENDING.add(new Pending(player, level, e.getPos().immutable(), e.getPlacedBlock()));
    }

    @SubscribeEvent
    public static void onServerTick(TickEvent.ServerTickEvent e) {
        if (e.phase != TickEvent.Phase.END || PENDING.isEmpty()) return;
        List<Pending> list = new ArrayList<>(PENDING);
        PENDING.clear();
        for (Pending pd : list) {
            if (!pd.player().isRemoved()) handle(pd);
        }
    }

    @SubscribeEvent
    public static void onLogout(PlayerEvent.PlayerLoggedOutEvent e) {
        STATES.remove(e.getEntity().getUUID());
    }

    private static void handle(Pending pd) {
        ServerPlayer p = pd.player();
        ServerLevel level = pd.level();
        BlockPos origin = pd.origin();
        if (level.getBlockState(origin).getBlock() != pd.state().getBlock()) return; // placement was cancelled
        BuildState s = get(p);

        if (s.anyMirror() && s.center == null) {
            s.center = p.blockPosition().below();
            bar(p, "§bMirror center set at your position", "تم وضع مركز المرآة عند موقعك");
        }

        List<BlockPos> base = List.of(origin);
        if (s.mode != 0) {
            if (s.first != null && level.dimension().equals(s.firstDim)) {
                BlockPos a = s.first;
                s.first = null;
                base = Shapes.shape(s.mode, a, origin);
                if (base == null) {
                    bar(p, "§cArea too large", "المساحة كبيرة جدًا");
                    sync(p, s);
                    return;
                }
            } else {
                s.first = origin;
                s.firstDim = level.dimension();
                bar(p, "§eStart point set, place the second block", "تم تحديد النقطة الأولى، ضع البلوك الثاني");
            }
        }

        List<BlockPos> all = Shapes.repeat(Shapes.mirror(base, s.mx, s.mz, s.my, s.center), s.count, s.dx, s.dy, s.dz);
        build(p, level, s, all, pd.state(), origin);
        sync(p, s);
    }

    private static void build(ServerPlayer p, ServerLevel level, BuildState s, List<BlockPos> list,
                              BlockState state, BlockPos origin) {
        boolean truncated = false;
        if (list.size() > Shapes.MAX_BLOCKS) {
            list = list.subList(0, Shapes.MAX_BLOCKS);
            truncated = true;
        }
        boolean survival = !p.getAbilities().instabuild;
        Item item = state.getBlock().asItem();
        int budget = survival ? (item == Items.AIR ? 0 : countItem(p, item)) : Integer.MAX_VALUE;

        List<BuildState.Rec> rec = new ArrayList<>();
        rec.add(new BuildState.Rec(origin, Blocks.AIR.defaultBlockState())); // the block the player placed
        int placed = 0;
        boolean outOfBlocks = false;

        for (BlockPos pos : list) {
            if (pos.equals(origin)) continue;
            if (pos.getY() < level.getMinBuildHeight() || pos.getY() >= level.getMaxBuildHeight()) continue;
            if (!level.isLoaded(pos) || !level.mayInteract(p, pos)) continue;
            BlockState old = level.getBlockState(pos);
            if (old.equals(state)) continue;
            if (placed >= budget) { outOfBlocks = true; break; }
            rec.add(new BuildState.Rec(pos, old));
            level.setBlock(pos, Block.updateFromNeighbourShapes(state, level, pos), 3);
            placed++;
        }
        if (survival && placed > 0) takeItem(p, item, placed);

        s.undo.addLast(new BuildState.UndoEntry(level.dimension(), rec, item, survival && item != Items.AIR));
        if (s.undo.size() > MAX_UNDO) s.undo.pollFirst();

        if (outOfBlocks) bar(p, "§cNot enough blocks (+" + placed + ")", "البلوكات غير كافية");
        else if (truncated) bar(p, "§cLimited to the first " + Shapes.MAX_BLOCKS + " blocks", "تم الاكتفاء بأول " + Shapes.MAX_BLOCKS + " بلوك");
        else if (placed > 0) bar(p, "§a+" + placed + " blocks", "+" + placed + " بلوك");
    }

    public static void undoLast(ServerPlayer p) {
        BuildState s = get(p);
        BuildState.UndoEntry e = s.undo.pollLast();
        if (e == null) {
            bar(p, "§cNothing to undo", "لا يوجد ما يمكن التراجع عنه");
            return;
        }
        ServerLevel level = p.server.getLevel(e.dim());
        int back = 0;
        if (level != null) {
            for (BuildState.Rec r : e.blocks()) {
                if (!level.isLoaded(r.pos())) continue;
                if (level.getBlockState(r.pos()).getBlock().asItem() == e.item()) back++; // still there -> refund
                level.setBlock(r.pos(), r.old(), 3);
            }
        }
        if (e.refund() && back > 0) give(p, e.item(), back);
        bar(p, "§eUndone", "تم التراجع");
    }

    public static void applySettings(ServerPlayer p, SettingsPacket pk) {
        BuildState s = get(p);
        int mode = Mth.clamp(pk.mode, 0, Shapes.MODES.length - 1);
        boolean toggled = pk.enabled != s.enabled;
        if (mode != s.mode || !pk.enabled) s.first = null;
        s.enabled = pk.enabled;
        s.mode = mode;
        s.mx = pk.mx; s.mz = pk.mz; s.my = pk.my;
        s.count = Mth.clamp(pk.count, 0, 20);
        s.dx = Mth.clamp(pk.dx, -10, 10);
        s.dy = Mth.clamp(pk.dy, -10, 10);
        s.dz = Mth.clamp(pk.dz, -10, 10);
        if (pk.setCenter || (s.anyMirror() && s.center == null)) s.center = p.blockPosition().below();

        if (pk.undo) undoLast(p);
        else if (toggled) {
            if (s.enabled) bar(p, "§aBuild mode ON", "وضع البناء مفعّل");
            else bar(p, "§cBuild mode OFF", "وضع البناء متوقف");
        } else bar(p, "§aSettings saved", "تم حفظ الإعدادات");
        sync(p, s);
    }

    private static int countItem(ServerPlayer p, Item item) {
        Inventory inv = p.getInventory();
        int n = 0;
        for (int i = 0; i < inv.getContainerSize(); i++) {
            ItemStack st = inv.getItem(i);
            if (st.is(item)) n += st.getCount();
        }
        return n;
    }

    private static void takeItem(ServerPlayer p, Item item, int amount) {
        Inventory inv = p.getInventory();
        for (int i = 0; i < inv.getContainerSize() && amount > 0; i++) {
            ItemStack st = inv.getItem(i);
            if (st.is(item)) {
                int t = Math.min(amount, st.getCount());
                st.shrink(t);
                amount -= t;
            }
        }
        inv.setChanged();
    }

    private static void give(ServerPlayer p, Item item, int n) {
        int max = new ItemStack(item).getMaxStackSize();
        while (n > 0) {
            int c = Math.min(n, max);
            n -= c;
            ItemStack st = new ItemStack(item, c);
            if (!p.getInventory().add(st)) p.drop(st, false);
        }
    }
}
EOF

cat > $J/client/ClientModEvents.java <<'EOF'
package com.abdou.easybuild.client;

import com.abdou.easybuild.ClientState;
import com.abdou.easybuild.EasyBuild;
import com.abdou.easybuild.Shapes;
import com.mojang.blaze3d.platform.InputConstants;
import net.minecraft.client.KeyMapping;
import net.minecraft.client.Minecraft;
import net.minecraft.network.chat.Component;
import net.minecraftforge.api.distmarker.Dist;
import net.minecraftforge.client.event.RegisterGuiOverlaysEvent;
import net.minecraftforge.client.event.RegisterKeyMappingsEvent;
import net.minecraftforge.client.gui.overlay.IGuiOverlay;
import net.minecraftforge.client.gui.overlay.VanillaGuiOverlay;
import net.minecraftforge.client.settings.KeyConflictContext;
import net.minecraftforge.client.settings.KeyModifier;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.fml.common.Mod;
import org.lwjgl.glfw.GLFW;

@Mod.EventBusSubscriber(modid = EasyBuild.MODID, value = Dist.CLIENT, bus = Mod.EventBusSubscriber.Bus.MOD)
public class ClientModEvents {
    public static final String CATEGORY = "key.categories.easybuild";

    /** B = open the menu */
    public static final KeyMapping MENU_KEY = new KeyMapping("key.easybuild.menu",
            KeyConflictContext.IN_GAME, InputConstants.Type.KEYSYM, GLFW.GLFW_KEY_B, CATEGORY);

    /** Ctrl+S = build mode on/off (plain S is "walk backwards" in Java) */
    public static final KeyMapping TOGGLE_KEY = new KeyMapping("key.easybuild.toggle",
            KeyConflictContext.IN_GAME, KeyModifier.CONTROL, InputConstants.Type.KEYSYM, GLFW.GLFW_KEY_S, CATEGORY);

    /** Text under the crosshair while build mode is on. */
    public static final IGuiOverlay HUD = (gui, g, partialTick, w, h) -> {
        Minecraft mc = Minecraft.getInstance();
        if (!ClientState.enabled || mc.options.hideGui || mc.player == null) return;
        String en = "Build: " + Shapes.MODES[ClientState.mode];
        String ar = "البناء: " + Shapes.MODES_AR[ClientState.mode];
        if (ClientState.mode != 0 && ClientState.first != null) {
            en += " (point 1 set)";
            ar += " (تم تحديد النقطة الأولى)";
        }
        g.drawCenteredString(mc.font, Component.literal(en), w / 2, h / 2 + 12, 0x55FFFF);
        g.drawCenteredString(mc.font, Component.literal(ar), w / 2, h / 2 + 22, 0xAAAAAA);
    };

    @SubscribeEvent
    public static void onKeys(RegisterKeyMappingsEvent e) {
        e.register(MENU_KEY);
        e.register(TOGGLE_KEY);
    }

    @SubscribeEvent
    public static void onOverlays(RegisterGuiOverlaysEvent e) {
        e.registerAbove(VanillaGuiOverlay.CROSSHAIR.id(), "easybuild_hud", HUD);
    }
}
EOF

cat > $J/client/ClientForgeEvents.java <<'EOF'
package com.abdou.easybuild.client;

import com.abdou.easybuild.ClientState;
import com.abdou.easybuild.EasyBuild;
import com.abdou.easybuild.Network;
import com.abdou.easybuild.Shapes;
import com.mojang.blaze3d.vertex.PoseStack;
import com.mojang.blaze3d.vertex.VertexConsumer;
import net.minecraft.client.Minecraft;
import net.minecraft.client.renderer.LevelRenderer;
import net.minecraft.client.renderer.MultiBufferSource;
import net.minecraft.client.renderer.RenderType;
import net.minecraft.core.BlockPos;
import net.minecraft.world.item.BlockItem;
import net.minecraft.world.phys.AABB;
import net.minecraft.world.phys.BlockHitResult;
import net.minecraft.world.phys.HitResult;
import net.minecraft.world.phys.Vec3;
import net.minecraftforge.api.distmarker.Dist;
import net.minecraftforge.client.event.ClientPlayerNetworkEvent;
import net.minecraftforge.client.event.RenderLevelStageEvent;
import net.minecraftforge.event.TickEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.fml.common.Mod;

import java.util.List;

@Mod.EventBusSubscriber(modid = EasyBuild.MODID, value = Dist.CLIENT, bus = Mod.EventBusSubscriber.Bus.FORGE)
public class ClientForgeEvents {
    private static final int MAX_PREVIEW = 1500;

    @SubscribeEvent
    public static void onTick(TickEvent.ClientTickEvent e) {
        if (e.phase != TickEvent.Phase.END) return;
        Minecraft mc = Minecraft.getInstance();
        if (mc.player == null) return;
        while (ClientModEvents.MENU_KEY.consumeClick()) {
            if (mc.screen == null) mc.setScreen(new EasyBuildScreen());
        }
        while (ClientModEvents.TOGGLE_KEY.consumeClick()) {
            ClientState.enabled = !ClientState.enabled;
            if (!ClientState.enabled) ClientState.first = null;
            Network.CHANNEL.sendToServer(ClientState.packet(false, false));
        }
    }

    @SubscribeEvent
    public static void onLogout(ClientPlayerNetworkEvent.LoggingOut e) {
        ClientState.reset();
    }

    /** Live preview: outlines of every block that will be placed. */
    @SubscribeEvent
    public static void onRender(RenderLevelStageEvent e) {
        if (e.getStage() != RenderLevelStageEvent.Stage.AFTER_TRANSLUCENT_BLOCKS) return;
        Minecraft mc = Minecraft.getInstance();
        if (!ClientState.enabled || mc.player == null || mc.level == null) return;
        if (!(mc.player.getMainHandItem().getItem() instanceof BlockItem)) return;

        List<BlockPos> blocks = compute(mc);
        if (blocks.isEmpty()) return;

        PoseStack ps = e.getPoseStack();
        Vec3 cam = e.getCamera().getPosition();
        MultiBufferSource.BufferSource buf = mc.renderBuffers().bufferSource();
        VertexConsumer vc = buf.getBuffer(RenderType.lines());
        ps.pushPose();
        ps.translate(-cam.x, -cam.y, -cam.z);
        int n = 0;
        for (BlockPos p : blocks) {
            if (n++ >= MAX_PREVIEW) break;
            LevelRenderer.renderLineBox(ps, vc, new AABB(p).inflate(0.002), 0.3f, 0.9f, 1.0f, 0.9f);
        }
        if (ClientState.mode != 0 && ClientState.first != null) {
            LevelRenderer.renderLineBox(ps, vc, new AABB(ClientState.first).inflate(0.01), 1.0f, 0.85f, 0.2f, 1.0f);
        }
        ps.popPose();
        buf.endBatch(RenderType.lines());
    }

    private static List<BlockPos> compute(Minecraft mc) {
        HitResult hr = mc.hitResult;
        if (!(hr instanceof BlockHitResult bhr) || hr.getType() != HitResult.Type.BLOCK) return List.of();
        BlockPos target = bhr.getBlockPos().relative(bhr.getDirection());
        List<BlockPos> base = List.of(target);
        if (ClientState.mode != 0 && ClientState.first != null) {
            base = Shapes.shape(ClientState.mode, ClientState.first, target);
            if (base == null) return List.of();
        }
        BlockPos center = ClientState.center != null ? ClientState.center : mc.player.blockPosition().below();
        return Shapes.repeat(Shapes.mirror(base, ClientState.mx, ClientState.mz, ClientState.my, center),
                ClientState.count, ClientState.dx, ClientState.dy, ClientState.dz);
    }
}
EOF

cat > $J/client/EasyBuildScreen.java <<'EOF'
package com.abdou.easybuild.client;

import com.abdou.easybuild.ClientState;
import com.abdou.easybuild.Network;
import com.abdou.easybuild.Shapes;
import net.minecraft.client.gui.GuiGraphics;
import net.minecraft.client.gui.components.Button;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.network.chat.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.function.BooleanSupplier;
import java.util.function.Consumer;
import java.util.function.IntConsumer;
import java.util.function.IntSupplier;
import java.util.function.Supplier;

/** Java version of the Bedrock form: English on the buttons, Arabic under each one. */
public class EasyBuildScreen extends Screen {
    private static final int W = 150, STEP = 32, GRAY = 0xAAAAAA;

    private record Caption(int x, int y, Supplier<Component> text) {}
    private final List<Caption> captions = new ArrayList<>();
    private int top;

    private boolean enabled = ClientState.enabled, mx = ClientState.mx, mz = ClientState.mz, my = ClientState.my;
    private int mode = ClientState.mode, count = ClientState.count;
    private int dx = ClientState.dx, dy = ClientState.dy, dz = ClientState.dz;
    private boolean setCenter = false;

    public EasyBuildScreen() {
        super(Component.literal("Easy build without items"));
    }

    @Override
    protected void init() {
        captions.clear();
        int cx = width / 2, lx = cx - 155, rx = cx + 5;
        top = Math.max(26, height / 2 - 96);

        // left column
        int y = top;
        toggle(lx, y, "Build mode", "تفعيل البناء (Ctrl+S)", () -> enabled, v -> enabled = v);
        y += STEP;
        addRenderableWidget(Button.builder(modeText(), b -> {
            mode = (mode + 1) % Shapes.MODES.length;
            b.setMessage(modeText());
        }).bounds(lx, y, W, 20).build());
        caption(lx, y, () -> Component.literal("الوضع: " + Shapes.MODES_AR[mode]));
        y += STEP;
        toggle(lx, y, "Mirror on X axis", "مرآة على محور X", () -> mx, v -> mx = v);
        y += STEP;
        toggle(lx, y, "Mirror on Z axis", "مرآة على محور Z", () -> mz, v -> mz = v);
        y += STEP;
        toggle(lx, y, "Mirror vertically (Y)", "مرآة عمودية (Y)", () -> my, v -> my = v);
        y += STEP;
        toggle(lx, y, "Set mirror center here", "ضع مركز المرآة عند موقعي", () -> setCenter, v -> setCenter = v);

        // right column
        y = top;
        stepper(rx, y, "Repeat", "عدد التكرار (0 = متوقف)", () -> count, v -> count = v, 0, 20);
        y += STEP;
        stepper(rx, y, "Offset X", "إزاحة التكرار X", () -> dx, v -> dx = v, -10, 10);
        y += STEP;
        stepper(rx, y, "Offset Y", "إزاحة التكرار Y", () -> dy, v -> dy = v, -10, 10);
        y += STEP;
        stepper(rx, y, "Offset Z", "إزاحة التكرار Z", () -> dz, v -> dz = v, -10, 10);
        y += STEP;
        addRenderableWidget(Button.builder(Component.literal("Undo last build"), b -> send(true))
                .bounds(rx, y, W, 20).build());
        caption(rx, y, () -> Component.literal("تراجع عن آخر بناء"));
        y += STEP;
        addRenderableWidget(Button.builder(Component.literal("§aSave"), b -> send(false))
                .bounds(rx, y, W, 20).build());
        caption(rx, y, () -> Component.literal("حفظ"));
    }

    private Component modeText() {
        return Component.literal("Mode: " + Shapes.MODES[mode]);
    }

    private static Component onOff(String name, boolean v) {
        return Component.literal(name + ": " + (v ? "§aON" : "§cOFF"));
    }

    private void caption(int x, int y, Supplier<Component> text) {
        captions.add(new Caption(x + W / 2, y + 22, text));
    }

    private void toggle(int x, int y, String en, String ar, BooleanSupplier get, Consumer<Boolean> set) {
        addRenderableWidget(Button.builder(onOff(en, get.getAsBoolean()), b -> {
            set.accept(!get.getAsBoolean());
            b.setMessage(onOff(en, get.getAsBoolean()));
        }).bounds(x, y, W, 20).build());
        caption(x, y, () -> Component.literal(ar + ": " + (get.getAsBoolean() ? "مفعّل" : "متوقف")));
    }

    private void stepper(int x, int y, String en, String ar, IntSupplier get, IntConsumer set, int min, int max) {
        Button label = Button.builder(Component.literal(en + ": " + get.getAsInt()), b -> {})
                .bounds(x + 22, y, W - 44, 20).build();
        label.active = false;
        addRenderableWidget(Button.builder(Component.literal("-"), b -> {
            set.accept(Math.max(min, get.getAsInt() - 1));
            label.setMessage(Component.literal(en + ": " + get.getAsInt()));
        }).bounds(x, y, 20, 20).build());
        addRenderableWidget(label);
        addRenderableWidget(Button.builder(Component.literal("+"), b -> {
            set.accept(Math.min(max, get.getAsInt() + 1));
            label.setMessage(Component.literal(en + ": " + get.getAsInt()));
        }).bounds(x + W - 20, y, 20, 20).build());
        caption(x, y, () -> Component.literal(ar));
    }

    private void send(boolean undo) {
        if (mode != ClientState.mode || !enabled) ClientState.first = null;
        ClientState.enabled = enabled;
        ClientState.mode = mode;
        ClientState.mx = mx; ClientState.mz = mz; ClientState.my = my;
        ClientState.count = count; ClientState.dx = dx; ClientState.dy = dy; ClientState.dz = dz;
        Network.CHANNEL.sendToServer(ClientState.packet(setCenter, undo));
        onClose();
    }

    @Override
    public void render(GuiGraphics g, int mouseX, int mouseY, float partialTick) {
        renderBackground(g);
        g.drawCenteredString(font, title, width / 2, top - 22, 0xFFFFFF);
        g.drawCenteredString(font, Component.literal("بناء سهل بدون أدوات"), width / 2, top - 12, GRAY);
        super.render(g, mouseX, mouseY, partialTick);
        for (Caption c : captions) g.drawCenteredString(font, c.text().get(), c.x(), c.y(), GRAY);
    }

    @Override
    public boolean isPauseScreen() {
        return false;
    }
}
EOF

echo "تم إنشاء كل الملفات ✅"#!/bin/bash
set -e
J=src/main/java/com/abdou/easybuild
mkdir -p $J/client src/main/resources/META-INF src/main/resources/assets/easybuild/lang .github/workflows

echo 'iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAYAAABccqhmAAADP0lEQVR4nO3WMRHCABREQRIHeEANQxFBCEpDS0+NqETGn8zbVXDVm1tej/tx47L+n+/0BC5snR4AzBEACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACBMACFvW/XdMj6Dr+d6mJ6R5ABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABAmABB2AlYoCS33/yfNAAAAAElFTkSuQmCC' | base64 -d > src/main/resources/logo.png

cat > settings.gradle <<'EOF'
pluginManagement {
    repositories {
        gradlePluginPortal()
        maven { name = 'MinecraftForge'; url = 'https://maven.minecraftforge.net/' }
    }
}
rootProject.name = 'easybuild'
EOF

cat > gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx3G
org.gradle.daemon=false
EOF

cat > build.gradle <<'EOF'
plugins {
    id 'eclipse'
    id 'net.minecraftforge.gradle' version '[6.0.16,6.2)'
}

version = '1.2.2'
group = 'com.abdou.easybuild'
base { archivesName = 'easy_build_without_items-forge-1.20.1' }

java.toolchain.languageVersion = JavaLanguageVersion.of(17)

minecraft {
    mappings channel: 'official', version: '1.20.1'
    runs {
        client {
            workingDirectory project.file('run')
            mods { easybuild { source sourceSets.main } }
        }
        server {
            workingDirectory project.file('run')
            mods { easybuild { source sourceSets.main } }
        }
    }
}

dependencies {
    minecraft 'net.minecraftforge:forge:1.20.1-47.3.0'
}

tasks.named('jar', Jar).configure {
    manifest {
        attributes(['Specification-Title': 'easybuild', 'Implementation-Version': project.version])
    }
    finalizedBy 'reobfJar'
}

tasks.withType(JavaCompile).configureEach { options.encoding = 'UTF-8' }
EOF

cat > .github/workflows/build.yml <<'EOF'
name: Build mod jar
on: [push, workflow_dispatch]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'
      - uses: gradle/actions/setup-gradle@v3
        with:
          gradle-version: '8.1.1'
      - run: gradle build --no-daemon
      - uses: actions/upload-artifact@v4
        with:
          name: easybuild-forge-jar
          path: build/libs/*.jar
EOF

cat > src/main/resources/META-INF/mods.toml <<'EOF'
modLoader="javafml"
loaderVersion="[47,)"
license="All Rights Reserved"

[[mods]]
modId="easybuild"
version="1.2.2"
displayName="Easy build without items"
authors="Abdou"
logoFile="logo.png"
description='''Effortless Building without items. Ctrl+S = build mode on/off, B = menu. Line, wall, roof, filled box, mirror, repeat, undo, live preview.'''

[[dependencies.easybuild]]
    modId="forge"
    mandatory=true
    versionRange="[47,)"
    ordering="NONE"
    side="BOTH"

[[dependencies.easybuild]]
    modId="minecraft"
    mandatory=true
    versionRange="[1.20.1,1.21)"
    ordering="NONE"
    side="BOTH"
EOF

cat > src/main/resources/pack.mcmeta <<'EOF'
{ "pack": { "description": "Easy build resources", "pack_format": 15 } }
EOF

cat > src/main/resources/assets/easybuild/lang/en_us.json <<'EOF'
{
  "key.categories.easybuild": "Easy build",
  "key.easybuild.menu": "Open Easy build menu",
  "key.easybuild.toggle": "Build mode on/off"
}
EOF

cat > $J/EasyBuild.java <<'EOF'
package com.abdou.easybuild;

import net.minecraftforge.common.MinecraftForge;
import net.minecraftforge.fml.common.Mod;

@Mod(EasyBuild.MODID)
public class EasyBuild {
    public static final String MODID = "easybuild";

    public EasyBuild() {
        Network.register();
        MinecraftForge.EVENT_BUS.register(BuildHandler.class);
    }
}
EOF

cat > $J/Network.java <<'EOF'
package com.abdou.easybuild;

import net.minecraft.resources.ResourceLocation;
import net.minecraft.server.level.ServerPlayer;
import net.minecraftforge.network.NetworkDirection;
import net.minecraftforge.network.NetworkRegistry;
import net.minecraftforge.network.PacketDistributor;
import net.minecraftforge.network.simple.SimpleChannel;

public class Network {
    private static final String VERSION = "2";
    public static final SimpleChannel CHANNEL = NetworkRegistry.newSimpleChannel(
            new ResourceLocation(EasyBuild.MODID, "main"), () -> VERSION, VERSION::equals, VERSION::equals);

    public static void register() {
        CHANNEL.messageBuilder(SettingsPacket.class, 0, NetworkDirection.PLAY_TO_SERVER)
                .encoder(SettingsPacket::encode)
                .decoder(SettingsPacket::new)
                .consumerMainThread(SettingsPacket::handle)
                .add();
        CHANNEL.messageBuilder(SyncPacket.class, 1, NetworkDirection.PLAY_TO_CLIENT)
                .encoder(SyncPacket::encode)
                .decoder(SyncPacket::new)
                .consumerMainThread(SyncPacket::handle)
                .add();
    }

    public static void sendTo(ServerPlayer player, Object msg) {
        CHANNEL.send(PacketDistributor.PLAYER.with(() -> player), msg);
    }
}
EOF

cat > $J/SettingsPacket.java <<'EOF'
package com.abdou.easybuild;

import net.minecraft.network.FriendlyByteBuf;
import net.minecraft.server.level.ServerPlayer;
import net.minecraftforge.network.NetworkEvent;

import java.util.function.Supplier;

public class SettingsPacket {
    public final boolean enabled, mx, mz, my, setCenter, undo;
    public final int mode, count, dx, dy, dz;

    public SettingsPacket(boolean enabled, int mode, boolean mx, boolean mz, boolean my, boolean setCenter,
                          int count, int dx, int dy, int dz, boolean undo) {
        this.enabled = enabled; this.mode = mode; this.mx = mx; this.mz = mz; this.my = my;
        this.setCenter = setCenter; this.count = count; this.dx = dx; this.dy = dy; this.dz = dz; this.undo = undo;
    }

    public SettingsPacket(FriendlyByteBuf b) {
        this(b.readBoolean(), b.readVarInt(), b.readBoolean(), b.readBoolean(), b.readBoolean(), b.readBoolean(),
                b.readVarInt(), b.readVarInt(), b.readVarInt(), b.readVarInt(), b.readBoolean());
    }

    public void encode(FriendlyByteBuf b) {
        b.writeBoolean(enabled); b.writeVarInt(mode); b.writeBoolean(mx); b.writeBoolean(mz); b.writeBoolean(my);
        b.writeBoolean(setCenter); b.writeVarInt(count); b.writeVarInt(dx); b.writeVarInt(dy); b.writeVarInt(dz);
        b.writeBoolean(undo);
    }

    public void handle(Supplier<NetworkEvent.Context> ctx) {
        ServerPlayer player = ctx.get().getSender();
        if (player != null) BuildHandler.applySettings(player, this);
    }
}
EOF

cat > $J/SyncPacket.java <<'EOF'
package com.abdou.easybuild;

import net.minecraft.core.BlockPos;
import net.minecraft.network.FriendlyByteBuf;
import net.minecraftforge.network.NetworkEvent;

import java.util.function.Supplier;

/** Server -> client: what the preview needs to know (build mode, first point, mirror center). */
public class SyncPacket {
    public final boolean enabled;
    public final BlockPos first, center;

    public SyncPacket(boolean enabled, BlockPos first, BlockPos center) {
        this.enabled = enabled; this.first = first; this.center = center;
    }

    public SyncPacket(FriendlyByteBuf b) {
        this.enabled = b.readBoolean();
        this.first = b.readBoolean() ? b.readBlockPos() : null;
        this.center = b.readBoolean() ? b.readBlockPos() : null;
    }

    public void encode(FriendlyByteBuf b) {
        b.writeBoolean(enabled);
        b.writeBoolean(first != null); if (first != null) b.writeBlockPos(first);
        b.writeBoolean(center != null); if (center != null) b.writeBlockPos(center);
    }

    public void handle(Supplier<NetworkEvent.Context> ctx) {
        ClientState.enabled = enabled;
        ClientState.first = first;
        ClientState.center = center;
    }
}
EOF

cat > $J/ClientState.java <<'EOF'
package com.abdou.easybuild;

import net.minecraft.core.BlockPos;

/** Client copy of the settings (plain data, safe on both sides). */
public final class ClientState {
    public static boolean enabled, mx, mz, my;
    public static int mode, count, dx, dy, dz;
    public static BlockPos first, center;

    static { reset(); }

    public static void reset() {
        enabled = false; mode = 1; mx = mz = my = false;
        count = 0; dx = 2; dy = 0; dz = 0;
        first = null; center = null;
    }

    public static SettingsPacket packet(boolean setCenter, boolean undo) {
        return new SettingsPacket(enabled, mode, mx, mz, my, setCenter, count, dx, dy, dz, undo);
    }
}
EOF

cat > $J/BuildState.java <<'EOF'
package com.abdou.easybuild;

import net.minecraft.core.BlockPos;
import net.minecraft.resources.ResourceKey;
import net.minecraft.world.item.Item;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.state.BlockState;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.List;

public class BuildState {
    public boolean enabled = false;
    public int mode = 1;
    public boolean mx, mz, my;
    public BlockPos center;
    public int count = 0, dx = 2, dy = 0, dz = 0;
    public BlockPos first;
    public ResourceKey<Level> firstDim;
    public final Deque<UndoEntry> undo = new ArrayDeque<>();

    public boolean anyMirror() { return mx || mz || my; }

    public record Rec(BlockPos pos, BlockState old) {}
    public record UndoEntry(ResourceKey<Level> dim, List<Rec> blocks, Item item, boolean refund) {}
}
EOF

cat > $J/Shapes.java <<'EOF'
package com.abdou.easybuild;

import net.minecraft.core.BlockPos;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/** Shape maths shared by the server (building) and the client (preview). */
public final class Shapes {
    public static final String[] MODES = {"Normal", "Line", "Wall", "Roof", "Filled Box"};
    public static final String[] MODES_AR = {"عادي", "خط", "جدار", "سقف", "صندوق ممتلئ"};
    public static final int MAX_BLOCKS = 4000;

    /** Returns null when the area is too large. */
    public static List<BlockPos> shape(int mode, BlockPos a, BlockPos b) {
        return switch (mode) {
            case 1 -> line(a, b);
            case 2 -> wall(a, b);
            case 3 -> roof(a, b);
            case 4 -> box(a, b);
            default -> List.of(b);
        };
    }

    public static List<BlockPos> line(BlockPos a, BlockPos b) {
        int dx = b.getX() - a.getX(), dy = b.getY() - a.getY(), dz = b.getZ() - a.getZ();
        int n = Math.max(Math.abs(dx), Math.max(Math.abs(dy), Math.abs(dz)));
        List<BlockPos> out = new ArrayList<>();
        for (int i = 0; i <= n; i++) {
            double t = n == 0 ? 0 : (double) i / n;
            out.add(new BlockPos((int) Math.round(a.getX() + dx * t),
                    (int) Math.round(a.getY() + dy * t), (int) Math.round(a.getZ() + dz * t)));
        }
        return out;
    }

    /** Vertical wall: line on the ground from a to b, raised from the lower to the higher point. */
    public static List<BlockPos> wall(BlockPos a, BlockPos b) {
        int dx = b.getX() - a.getX(), dz = b.getZ() - a.getZ();
        int n = Math.max(Math.abs(dx), Math.abs(dz));
        int y0 = Math.min(a.getY(), b.getY()), y1 = Math.max(a.getY(), b.getY());
        if ((long) (n + 1) * (y1 - y0 + 1) > MAX_BLOCKS) return null;
        Set<BlockPos> out = new LinkedHashSet<>();
        for (int i = 0; i <= n; i++) {
            double t = n == 0 ? 0 : (double) i / n;
            int x = (int) Math.round(a.getX() + dx * t), z = (int) Math.round(a.getZ() + dz * t);
            for (int y = y0; y <= y1; y++) out.add(new BlockPos(x, y, z));
        }
        return new ArrayList<>(out);
    }

    /** Flat roof/floor at the height of the first point. */
    public static List<BlockPos> roof(BlockPos a, BlockPos b) {
        int x0 = Math.min(a.getX(), b.getX()), x1 = Math.max(a.getX(), b.getX());
        int z0 = Math.min(a.getZ(), b.getZ()), z1 = Math.max(a.getZ(), b.getZ());
        if ((long) (x1 - x0 + 1) * (z1 - z0 + 1) > MAX_BLOCKS) return null;
        List<BlockPos> out = new ArrayList<>();
        for (int x = x0; x <= x1; x++)
            for (int z = z0; z <= z1; z++) out.add(new BlockPos(x, a.getY(), z));
        return out;
    }

    public static List<BlockPos> box(BlockPos a, BlockPos b) {
        int x0 = Math.min(a.getX(), b.getX()), x1 = Math.max(a.getX(), b.getX());
        int y0 = Math.min(a.getY(), b.getY()), y1 = Math.max(a.getY(), b.getY());
        int z0 = Math.min(a.getZ(), b.getZ()), z1 = Math.max(a.getZ(), b.getZ());
        if ((long) (x1 - x0 + 1) * (y1 - y0 + 1) * (z1 - z0 + 1) > MAX_BLOCKS) return null;
        List<BlockPos> out = new ArrayList<>();
        for (int x = x0; x <= x1; x++)
            for (int y = y0; y <= y1; y++)
                for (int z = z0; z <= z1; z++) out.add(new BlockPos(x, y, z));
        return out;
    }

    public static List<BlockPos> mirror(List<BlockPos> list, boolean mx, boolean mz, boolean my, BlockPos c) {
        if (!(mx || mz || my) || c == null) return list;
        Set<BlockPos> out = new LinkedHashSet<>();
        for (BlockPos p : list) {
            int[] xs = mx ? new int[]{p.getX(), 2 * c.getX() - p.getX()} : new int[]{p.getX()};
            int[] ys = my ? new int[]{p.getY(), 2 * c.getY() - p.getY()} : new int[]{p.getY()};
            int[] zs = mz ? new int[]{p.getZ(), 2 * c.getZ() - p.getZ()} : new int[]{p.getZ()};
            for (int x : xs) for (int y : ys) for (int z : zs) out.add(new BlockPos(x, y, z));
        }
        return new ArrayList<>(out);
    }

    public static List<BlockPos> repeat(List<BlockPos> list, int count, int dx, int dy, int dz) {
        if (count <= 0) return list;
        Set<BlockPos> out = new LinkedHashSet<>();
        for (BlockPos p : list) {
            out.add(p);
            for (int i = 1; i <= count; i++) out.add(p.offset(dx * i, dy * i, dz * i));
            if (out.size() > MAX_BLOCKS * 2) break;
        }
        return new ArrayList<>(out);
    }
}
EOF

cat > $J/BuildHandler.java <<'EOF'
package com.abdou.easybuild;

import net.minecraft.core.BlockPos;
import net.minecraft.network.chat.Component;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.util.Mth;
import net.minecraft.world.entity.player.Inventory;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraftforge.event.TickEvent;
import net.minecraftforge.event.entity.player.PlayerEvent;
import net.minecraftforge.event.level.BlockEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class BuildHandler {
    private static final int MAX_UNDO = 10;
    private static final Map<UUID, BuildState> STATES = new HashMap<>();
    private static final List<Pending> PENDING = new ArrayList<>();

    private record Pending(ServerPlayer player, ServerLevel level, BlockPos origin, BlockState state) {}

    public static BuildState get(Player p) {
        return STATES.computeIfAbsent(p.getUUID(), k -> new BuildState());
    }

    private static void bar(Player p, String en, String ar) {
        p.displayClientMessage(Component.literal(en + " §7| " + ar), true);
    }

    private static void sync(ServerPlayer p, BuildState s) {
        Network.sendTo(p, new SyncPacket(s.enabled, s.first, s.center));
    }

    @SubscribeEvent
    public static void onPlace(BlockEvent.EntityPlaceEvent e) {
        if (e instanceof BlockEvent.EntityMultiPlaceEvent) return; // doors, beds...
        if (!(e.getEntity() instanceof ServerPlayer player)) return;
        if (!(e.getLevel() instanceof ServerLevel level)) return;
        if (!get(player).enabled) return;
        // run after vanilla finished placing (so item counts stay correct)
        PENDING.add(new Pending(player, level, e.getPos().immutable(), e.getPlacedBlock()));
    }

    @SubscribeEvent
    public static void onServerTick(TickEvent.ServerTickEvent e) {
        if (e.phase != TickEvent.Phase.END || PENDING.isEmpty()) return;
        List<Pending> list = new ArrayList<>(PENDING);
        PENDING.clear();
        for (Pending pd : list) {
            if (!pd.player().isRemoved()) handle(pd);
        }
    }

    @SubscribeEvent
    public static void onLogout(PlayerEvent.PlayerLoggedOutEvent e) {
        STATES.remove(e.getEntity().getUUID());
    }

    private static void handle(Pending pd) {
        ServerPlayer p = pd.player();
        ServerLevel level = pd.level();
        BlockPos origin = pd.origin();
        if (level.getBlockState(origin).getBlock() != pd.state().getBlock()) return; // placement was cancelled
        BuildState s = get(p);

        if (s.anyMirror() && s.center == null) {
            s.center = p.blockPosition().below();
            bar(p, "§bMirror center set at your position", "تم وضع مركز المرآة عند موقعك");
        }

        List<BlockPos> base = List.of(origin);
        if (s.mode != 0) {
            if (s.first != null && level.dimension().equals(s.firstDim)) {
                BlockPos a = s.first;
                s.first = null;
                base = Shapes.shape(s.mode, a, origin);
                if (base == null) {
                    bar(p, "§cArea too large", "المساحة كبيرة جدًا");
                    sync(p, s);
                    return;
                }
            } else {
                s.first = origin;
                s.firstDim = level.dimension();
                bar(p, "§eStart point set, place the second block", "تم تحديد النقطة الأولى، ضع البلوك الثاني");
            }
        }

        List<BlockPos> all = Shapes.repeat(Shapes.mirror(base, s.mx, s.mz, s.my, s.center), s.count, s.dx, s.dy, s.dz);
        build(p, level, s, all, pd.state(), origin);
        sync(p, s);
    }

    private static void build(ServerPlayer p, ServerLevel level, BuildState s, List<BlockPos> list,
                              BlockState state, BlockPos origin) {
        boolean truncated = false;
        if (list.size() > Shapes.MAX_BLOCKS) {
            list = list.subList(0, Shapes.MAX_BLOCKS);
            truncated = true;
        }
        boolean survival = !p.getAbilities().instabuild;
        Item item = state.getBlock().asItem();
        int budget = survival ? (item == Items.AIR ? 0 : countItem(p, item)) : Integer.MAX_VALUE;

        List<BuildState.Rec> rec = new ArrayList<>();
        rec.add(new BuildState.Rec(origin, Blocks.AIR.defaultBlockState())); // the block the player placed
        int placed = 0;
        boolean outOfBlocks = false;

        for (BlockPos pos : list) {
            if (pos.equals(origin)) continue;
            if (pos.getY() < level.getMinBuildHeight() || pos.getY() >= level.getMaxBuildHeight()) continue;
            if (!level.isLoaded(pos) || !level.mayInteract(p, pos)) continue;
            BlockState old = level.getBlockState(pos);
            if (old.equals(state)) continue;
            if (placed >= budget) { outOfBlocks = true; break; }
            rec.add(new BuildState.Rec(pos, old));
            level.setBlock(pos, Block.updateFromNeighbourShapes(state, level, pos), 3);
            placed++;
        }
        if (survival && placed > 0) takeItem(p, item, placed);

        s.undo.addLast(new BuildState.UndoEntry(level.dimension(), rec, item, survival && item != Items.AIR));
        if (s.undo.size() > MAX_UNDO) s.undo.pollFirst();

        if (outOfBlocks) bar(p, "§cNot enough blocks (+" + placed + ")", "البلوكات غير كافية");
        else if (truncated) bar(p, "§cLimited to the first " + Shapes.MAX_BLOCKS + " blocks", "تم الاكتفاء بأول " + Shapes.MAX_BLOCKS + " بلوك");
        else if (placed > 0) bar(p, "§a+" + placed + " blocks", "+" + placed + " بلوك");
    }

    public static void undoLast(ServerPlayer p) {
        BuildState s = get(p);
        BuildState.UndoEntry e = s.undo.pollLast();
        if (e == null) {
            bar(p, "§cNothing to undo", "لا يوجد ما يمكن التراجع عنه");
            return;
        }
        ServerLevel level = p.server.getLevel(e.dim());
        int back = 0;
        if (level != null) {
            for (BuildState.Rec r : e.blocks()) {
                if (!level.isLoaded(r.pos())) continue;
                if (level.getBlockState(r.pos()).getBlock().asItem() == e.item()) back++; // still there -> refund
                level.setBlock(r.pos(), r.old(), 3);
            }
        }
        if (e.refund() && back > 0) give(p, e.item(), back);
        bar(p, "§eUndone", "تم التراجع");
    }

    public static void applySettings(ServerPlayer p, SettingsPacket pk) {
        BuildState s = get(p);
        int mode = Mth.clamp(pk.mode, 0, Shapes.MODES.length - 1);
        boolean toggled = pk.enabled != s.enabled;
        if (mode != s.mode || !pk.enabled) s.first = null;
        s.enabled = pk.enabled;
        s.mode = mode;
        s.mx = pk.mx; s.mz = pk.mz; s.my = pk.my;
        s.count = Mth.clamp(pk.count, 0, 20);
        s.dx = Mth.clamp(pk.dx, -10, 10);
        s.dy = Mth.clamp(pk.dy, -10, 10);
        s.dz = Mth.clamp(pk.dz, -10, 10);
        if (pk.setCenter || (s.anyMirror() && s.center == null)) s.center = p.blockPosition().below();

        if (pk.undo) undoLast(p);
        else if (toggled) {
            if (s.enabled) bar(p, "§aBuild mode ON", "وضع البناء مفعّل");
            else bar(p, "§cBuild mode OFF", "وضع البناء متوقف");
        } else bar(p, "§aSettings saved", "تم حفظ الإعدادات");
        sync(p, s);
    }

    private static int countItem(ServerPlayer p, Item item) {
        Inventory inv = p.getInventory();
        int n = 0;
        for (int i = 0; i < inv.getContainerSize(); i++) {
            ItemStack st = inv.getItem(i);
            if (st.is(item)) n += st.getCount();
        }
        return n;
    }

    private static void takeItem(ServerPlayer p, Item item, int amount) {
        Inventory inv = p.getInventory();
        for (int i = 0; i < inv.getContainerSize() && amount > 0; i++) {
            ItemStack st = inv.getItem(i);
            if (st.is(item)) {
                int t = Math.min(amount, st.getCount());
                st.shrink(t);
                amount -= t;
            }
        }
        inv.setChanged();
    }

    private static void give(ServerPlayer p, Item item, int n) {
        int max = new ItemStack(item).getMaxStackSize();
        while (n > 0) {
            int c = Math.min(n, max);
            n -= c;
            ItemStack st = new ItemStack(item, c);
            if (!p.getInventory().add(st)) p.drop(st, false);
        }
    }
}
EOF

cat > $J/client/ClientModEvents.java <<'EOF'
package com.abdou.easybuild.client;

import com.abdou.easybuild.ClientState;
import com.abdou.easybuild.EasyBuild;
import com.abdou.easybuild.Shapes;
import com.mojang.blaze3d.platform.InputConstants;
import net.minecraft.client.KeyMapping;
import net.minecraft.client.Minecraft;
import net.minecraft.network.chat.Component;
import net.minecraftforge.api.distmarker.Dist;
import net.minecraftforge.client.event.RegisterGuiOverlaysEvent;
import net.minecraftforge.client.event.RegisterKeyMappingsEvent;
import net.minecraftforge.client.gui.overlay.IGuiOverlay;
import net.minecraftforge.client.gui.overlay.VanillaGuiOverlay;
import net.minecraftforge.client.settings.KeyConflictContext;
import net.minecraftforge.client.settings.KeyModifier;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.fml.common.Mod;
import org.lwjgl.glfw.GLFW;

@Mod.EventBusSubscriber(modid = EasyBuild.MODID, value = Dist.CLIENT, bus = Mod.EventBusSubscriber.Bus.MOD)
public class ClientModEvents {
    public static final String CATEGORY = "key.categories.easybuild";

    /** B = open the menu */
    public static final KeyMapping MENU_KEY = new KeyMapping("key.easybuild.menu",
            KeyConflictContext.IN_GAME, InputConstants.Type.KEYSYM, GLFW.GLFW_KEY_B, CATEGORY);

    /** Ctrl+S = build mode on/off (plain S is "walk backwards" in Java) */
    public static final KeyMapping TOGGLE_KEY = new KeyMapping("key.easybuild.toggle",
            KeyConflictContext.IN_GAME, KeyModifier.CONTROL, InputConstants.Type.KEYSYM, GLFW.GLFW_KEY_S, CATEGORY);

    /** Text under the crosshair while build mode is on. */
    public static final IGuiOverlay HUD = (gui, g, partialTick, w, h) -> {
        Minecraft mc = Minecraft.getInstance();
        if (!ClientState.enabled || mc.options.hideGui || mc.player == null) return;
        String en = "Build: " + Shapes.MODES[ClientState.mode];
        String ar = "البناء: " + Shapes.MODES_AR[ClientState.mode];
        if (ClientState.mode != 0 && ClientState.first != null) {
            en += " (point 1 set)";
            ar += " (تم تحديد النقطة الأولى)";
        }
        g.drawCenteredString(mc.font, Component.literal(en), w / 2, h / 2 + 12, 0x55FFFF);
        g.drawCenteredString(mc.font, Component.literal(ar), w / 2, h / 2 + 22, 0xAAAAAA);
    };

    @SubscribeEvent
    public static void onKeys(RegisterKeyMappingsEvent e) {
        e.register(MENU_KEY);
        e.register(TOGGLE_KEY);
    }

    @SubscribeEvent
    public static void onOverlays(RegisterGuiOverlaysEvent e) {
        e.registerAbove(VanillaGuiOverlay.CROSSHAIR.id(), "easybuild_hud", HUD);
    }
}
EOF

cat > $J/client/ClientForgeEvents.java <<'EOF'
package com.abdou.easybuild.client;

import com.abdou.easybuild.ClientState;
import com.abdou.easybuild.EasyBuild;
import com.abdou.easybuild.Network;
import com.abdou.easybuild.Shapes;
import com.mojang.blaze3d.vertex.PoseStack;
import com.mojang.blaze3d.vertex.VertexConsumer;
import net.minecraft.client.Minecraft;
import net.minecraft.client.renderer.LevelRenderer;
import net.minecraft.client.renderer.MultiBufferSource;
import net.minecraft.client.renderer.RenderType;
import net.minecraft.core.BlockPos;
import net.minecraft.world.item.BlockItem;
import net.minecraft.world.phys.AABB;
import net.minecraft.world.phys.BlockHitResult;
import net.minecraft.world.phys.HitResult;
import net.minecraft.world.phys.Vec3;
import net.minecraftforge.api.distmarker.Dist;
import net.minecraftforge.client.event.ClientPlayerNetworkEvent;
import net.minecraftforge.client.event.RenderLevelStageEvent;
import net.minecraftforge.event.TickEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.fml.common.Mod;

import java.util.List;

@Mod.EventBusSubscriber(modid = EasyBuild.MODID, value = Dist.CLIENT, bus = Mod.EventBusSubscriber.Bus.FORGE)
public class ClientForgeEvents {
    private static final int MAX_PREVIEW = 1500;

    @SubscribeEvent
    public static void onTick(TickEvent.ClientTickEvent e) {
        if (e.phase != TickEvent.Phase.END) return;
        Minecraft mc = Minecraft.getInstance();
        if (mc.player == null) return;
        while (ClientModEvents.MENU_KEY.consumeClick()) {
            if (mc.screen == null) mc.setScreen(new EasyBuildScreen());
        }
        while (ClientModEvents.TOGGLE_KEY.consumeClick()) {
            ClientState.enabled = !ClientState.enabled;
            if (!ClientState.enabled) ClientState.first = null;
            Network.CHANNEL.sendToServer(ClientState.packet(false, false));
        }
    }

    @SubscribeEvent
    public static void onLogout(ClientPlayerNetworkEvent.LoggingOut e) {
        ClientState.reset();
    }

    /** Live preview: outlines of every block that will be placed. */
    @SubscribeEvent
    public static void onRender(RenderLevelStageEvent e) {
        if (e.getStage() != RenderLevelStageEvent.Stage.AFTER_TRANSLUCENT_BLOCKS) return;
        Minecraft mc = Minecraft.getInstance();
        if (!ClientState.enabled || mc.player == null || mc.level == null) return;
        if (!(mc.player.getMainHandItem().getItem() instanceof BlockItem)) return;

        List<BlockPos> blocks = compute(mc);
        if (blocks.isEmpty()) return;

        PoseStack ps = e.getPoseStack();
        Vec3 cam = e.getCamera().getPosition();
        MultiBufferSource.BufferSource buf = mc.renderBuffers().bufferSource();
        VertexConsumer vc = buf.getBuffer(RenderType.lines());
        ps.pushPose();
        ps.translate(-cam.x, -cam.y, -cam.z);
        int n = 0;
        for (BlockPos p : blocks) {
            if (n++ >= MAX_PREVIEW) break;
            LevelRenderer.renderLineBox(ps, vc, new AABB(p).inflate(0.002), 0.3f, 0.9f, 1.0f, 0.9f);
        }
        if (ClientState.mode != 0 && ClientState.first != null) {
            LevelRenderer.renderLineBox(ps, vc, new AABB(ClientState.first).inflate(0.01), 1.0f, 0.85f, 0.2f, 1.0f);
        }
        ps.popPose();
        buf.endBatch(RenderType.lines());
    }

    private static List<BlockPos> compute(Minecraft mc) {
        HitResult hr = mc.hitResult;
        if (!(hr instanceof BlockHitResult bhr) || hr.getType() != HitResult.Type.BLOCK) return List.of();
        BlockPos target = bhr.getBlockPos().relative(bhr.getDirection());
        List<BlockPos> base = List.of(target);
        if (ClientState.mode != 0 && ClientState.first != null) {
            base = Shapes.shape(ClientState.mode, ClientState.first, target);
            if (base == null) return List.of();
        }
        BlockPos center = ClientState.center != null ? ClientState.center : mc.player.blockPosition().below();
        return Shapes.repeat(Shapes.mirror(base, ClientState.mx, ClientState.mz, ClientState.my, center),
                ClientState.count, ClientState.dx, ClientState.dy, ClientState.dz);
    }
}
EOF

cat > $J/client/EasyBuildScreen.java <<'EOF'
package com.abdou.easybuild.client;

import com.abdou.easybuild.ClientState;
import com.abdou.easybuild.Network;
import com.abdou.easybuild.Shapes;
import net.minecraft.client.gui.GuiGraphics;
import net.minecraft.client.gui.components.Button;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.network.chat.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.function.BooleanSupplier;
import java.util.function.Consumer;
import java.util.function.IntConsumer;
import java.util.function.IntSupplier;
import java.util.function.Supplier;

/** Java version of the Bedrock form: English on the buttons, Arabic under each one. */
public class EasyBuildScreen extends Screen {
    private static final int W = 150, STEP = 32, GRAY = 0xAAAAAA;

    private record Caption(int x, int y, Supplier<Component> text) {}
    private final List<Caption> captions = new ArrayList<>();
    private int top;

    private boolean enabled = ClientState.enabled, mx = ClientState.mx, mz = ClientState.mz, my = ClientState.my;
    private int mode = ClientState.mode, count = ClientState.count;
    private int dx = ClientState.dx, dy = ClientState.dy, dz = ClientState.dz;
    private boolean setCenter = false;

    public EasyBuildScreen() {
        super(Component.literal("Easy build without items"));
    }

    @Override
    protected void init() {
        captions.clear();
        int cx = width / 2, lx = cx - 155, rx = cx + 5;
        top = Math.max(26, height / 2 - 96);

        // left column
        int y = top;
        toggle(lx, y, "Build mode", "تفعيل البناء (Ctrl+S)", () -> enabled, v -> enabled = v);
        y += STEP;
        addRenderableWidget(Button.builder(modeText(), b -> {
            mode = (mode + 1) % Shapes.MODES.length;
            b.setMessage(modeText());
        }).bounds(lx, y, W, 20).build());
        caption(lx, y, () -> Component.literal("الوضع: " + Shapes.MODES_AR[mode]));
        y += STEP;
        toggle(lx, y, "Mirror on X axis", "مرآة على محور X", () -> mx, v -> mx = v);
        y += STEP;
        toggle(lx, y, "Mirror on Z axis", "مرآة على محور Z", () -> mz, v -> mz = v);
        y += STEP;
        toggle(lx, y, "Mirror vertically (Y)", "مرآة عمودية (Y)", () -> my, v -> my = v);
        y += STEP;
        toggle(lx, y, "Set mirror center here", "ضع مركز المرآة عند موقعي", () -> setCenter, v -> setCenter = v);

        // right column
        y = top;
        stepper(rx, y, "Repeat", "عدد التكرار (0 = متوقف)", () -> count, v -> count = v, 0, 20);
        y += STEP;
        stepper(rx, y, "Offset X", "إزاحة التكرار X", () -> dx, v -> dx = v, -10, 10);
        y += STEP;
        stepper(rx, y, "Offset Y", "إزاحة التكرار Y", () -> dy, v -> dy = v, -10, 10);
        y += STEP;
        stepper(rx, y, "Offset Z", "إزاحة التكرار Z", () -> dz, v -> dz = v, -10, 10);
        y += STEP;
        addRenderableWidget(Button.builder(Component.literal("Undo last build"), b -> send(true))
                .bounds(rx, y, W, 20).build());
        caption(rx, y, () -> Component.literal("تراجع عن آخر بناء"));
        y += STEP;
        addRenderableWidget(Button.builder(Component.literal("§aSave"), b -> send(false))
                .bounds(rx, y, W, 20).build());
        caption(rx, y, () -> Component.literal("حفظ"));
    }

    private Component modeText() {
        return Component.literal("Mode: " + Shapes.MODES[mode]);
    }

    private static Component onOff(String name, boolean v) {
        return Component.literal(name + ": " + (v ? "§aON" : "§cOFF"));
    }

    private void caption(int x, int y, Supplier<Component> text) {
        captions.add(new Caption(x + W / 2, y + 22, text));
    }

    private void toggle(int x, int y, String en, String ar, BooleanSupplier get, Consumer<Boolean> set) {
        addRenderableWidget(Button.builder(onOff(en, get.getAsBoolean()), b -> {
            set.accept(!get.getAsBoolean());
            b.setMessage(onOff(en, get.getAsBoolean()));
        }).bounds(x, y, W, 20).build());
        caption(x, y, () -> Component.literal(ar + ": " + (get.getAsBoolean() ? "مفعّل" : "متوقف")));
    }

    private void stepper(int x, int y, String en, String ar, IntSupplier get, IntConsumer set, int min, int max) {
        Button label = Button.builder(Component.literal(en + ": " + get.getAsInt()), b -> {})
                .bounds(x + 22, y, W - 44, 20).build();
        label.active = false;
        addRenderableWidget(Button.builder(Component.literal("-"), b -> {
            set.accept(Math.max(min, get.getAsInt() - 1));
            label.setMessage(Component.literal(en + ": " + get.getAsInt()));
        }).bounds(x, y, 20, 20).build());
        addRenderableWidget(label);
        addRenderableWidget(Button.builder(Component.literal("+"), b -> {
            set.accept(Math.min(max, get.getAsInt() + 1));
            label.setMessage(Component.literal(en + ": " + get.getAsInt()));
        }).bounds(x + W - 20, y, 20, 20).build());
        caption(x, y, () -> Component.literal(ar));
    }

    private void send(boolean undo) {
        if (mode != ClientState.mode || !enabled) ClientState.first = null;
        ClientState.enabled = enabled;
        ClientState.mode = mode;
        ClientState.mx = mx; ClientState.mz = mz; ClientState.my = my;
        ClientState.count = count; ClientState.dx = dx; ClientState.dy = dy; ClientState.dz = dz;
        Network.CHANNEL.sendToServer(ClientState.packet(setCenter, undo));
        onClose();
    }

    @Override
    public void render(GuiGraphics g, int mouseX, int mouseY, float partialTick) {
        renderBackground(g);
        g.drawCenteredString(font, title, width / 2, top - 22, 0xFFFFFF);
        g.drawCenteredString(font, Component.literal("بناء سهل بدون أدوات"), width / 2, top - 12, GRAY);
        super.render(g, mouseX, mouseY, partialTick);
        for (Caption c : captions) g.drawCenteredString(font, c.text().get(), c.x(), c.y(), GRAY);
    }

    @Override
    public boolean isPauseScreen() {
        return false;
    }
}
EOF

echo "تم إنشاء كل الملفات ✅"
