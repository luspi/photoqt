/**************************************************************************
 *
 * Copyright (C) 2011-2026 Lukas Spies
 * Contact: https://photoqt.org
 *
 * This file is part of PhotoQt. It is based on wayland-info.c:
 * https://gitlab.freedesktop.org/wayland/wayland-utils
 *
 **************************************************************************
 * original copyright notice below:
 **************************************************************************
 *
 * Copyright © 2012 Philipp Brüschweiler
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice (including the next
 * paragraph) shall be included in all copies or substantial portions of the
 * Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#ifdef PQMWAYLANDSPECIFIC

// the implementation of the respective class is at the end of this file
#include <pqc_wayland.h>
#include <QtDebug>

#include <cerrno>
#include <cstdlib>
#include <cstring>
#include <cmath>
#include <map>

#include <cstdint>

#include <wayland-client.h>

extern "C" {
    #include <pqc_xdg-output-unstable-v1-client-protocol.h>
}

typedef void (*PQCWAYLAND_collect_info_t)(void *info);
typedef void (*PQCWAYLAND_destroy_info_t)(void *info);

std::map<int, int[2]> PQCWAYLAND_final_data;
std::map<std::string, int> PQCWAYLAND_final_screens;

struct PQCWAYLAND_wayland_global_info {
    struct wl_list link;

    uint32_t id;
    uint32_t version;

    PQCWAYLAND_collect_info_t collect;
    PQCWAYLAND_destroy_info_t destroy;
};

struct PQCWAYLAND_output_info {
    struct PQCWAYLAND_wayland_global_info global;
    struct wl_list global_link;

    struct wl_output *output;

    int32_t version;

    // we only keep track of width, that's sufficient for our use case
    int32_t actual_width;
    std::string model_name;

};

struct PQCWAYLAND_xdg_output_v1_info {
    struct wl_list link;

    struct zxdg_output_v1 *xdg_output;
    struct PQCWAYLAND_output_info *output;

    // we only keep track of width, that's sufficient for our use case
    int32_t logical_width;

};

struct PQCWAYLAND_xdg_output_manager_v1_info {
    struct PQCWAYLAND_wayland_global_info global;
    struct zxdg_output_manager_v1 *manager;
    struct PQCWAYLAND_wayland_info *info;

    struct wl_list outputs;
};

struct PQCWAYLAND_wayland_info {
    struct wl_display *display;
    struct wl_registry *registry;

    struct wl_list infos;
    bool roundtrip_needed;

    /* required for xdg-output-unstable-v1 */
    struct wl_list outputs;
    struct PQCWAYLAND_xdg_output_manager_v1_info *xdg_output_manager_v1_info;
};

static void PQCWAYLAND_init_global_info(struct PQCWAYLAND_wayland_info *info, struct PQCWAYLAND_wayland_global_info *global, uint32_t id, const char *interface, uint32_t version) {
    global->id = id;
    global->version = version;

    wl_list_insert(info->infos.prev, &global->link);
}

static void PQCWAYLAND_collect_output_info(void *data) {
    struct PQCWAYLAND_output_info *output = static_cast<PQCWAYLAND_output_info*>(data);
    struct PQCWAYLAND_wayland_global_info *global = static_cast<PQCWAYLAND_wayland_global_info*>(data);

    PQCWAYLAND_final_data[global->id][1] = output->actual_width;
    PQCWAYLAND_final_screens[output->model_name] = global->id;

}

static void PQCWAYLAND_destroy_xdg_output_v1_info(struct PQCWAYLAND_xdg_output_v1_info *info) {
    wl_list_remove(&info->link);
    zxdg_output_v1_destroy(info->xdg_output);
    free(info);
}

static void PQCWAYLAND_collect_xdg_output_v1_info(const struct PQCWAYLAND_xdg_output_v1_info *info) {

    PQCWAYLAND_final_data[info->output->global.id][0] = info->logical_width;

}

static void PQCWAYLAND_collect_xdg_output_manager_v1_info(void *data) {
    struct PQCWAYLAND_xdg_output_manager_v1_info *info = static_cast<PQCWAYLAND_xdg_output_manager_v1_info*>(data);
    struct PQCWAYLAND_xdg_output_v1_info *output;

    wl_list_for_each(output, &info->outputs, link)
        PQCWAYLAND_collect_xdg_output_v1_info(output);
}

static void PQCWAYLAND_destroy_xdg_output_manager_v1_info(void *data) {
    struct PQCWAYLAND_xdg_output_manager_v1_info *info = static_cast<PQCWAYLAND_xdg_output_manager_v1_info*>(data);
    struct PQCWAYLAND_xdg_output_v1_info *output, *tmp;

    zxdg_output_manager_v1_destroy(info->manager);

    wl_list_for_each_safe(output, tmp, &info->outputs, link)
        PQCWAYLAND_destroy_xdg_output_v1_info(output);
}

static void PQCWAYLAND_handle_xdg_output_v1_logical_position(void *data, struct zxdg_output_v1 *output, int32_t x, int32_t y) {}

static void PQCWAYLAND_handle_xdg_output_v1_logical_size(void *data, struct zxdg_output_v1 *output, int32_t width, int32_t height) {
    struct PQCWAYLAND_xdg_output_v1_info *xdg_output = static_cast<PQCWAYLAND_xdg_output_v1_info*>(data);
    xdg_output->logical_width = width;
}

static void PQCWAYLAND_handle_xdg_output_v1_done(void *data, struct zxdg_output_v1 *output) {}

static void PQCWAYLAND_handle_xdg_output_v1_name(void *data, struct zxdg_output_v1 *output, const char *name) {}

static void PQCWAYLAND_handle_xdg_output_v1_description(void *data, struct zxdg_output_v1 *output, const char *description) {}

static const struct zxdg_output_v1_listener xdg_output_v1_listener = {
    .logical_position = PQCWAYLAND_handle_xdg_output_v1_logical_position,
    .logical_size = PQCWAYLAND_handle_xdg_output_v1_logical_size,
    .done = PQCWAYLAND_handle_xdg_output_v1_done,
    .name = PQCWAYLAND_handle_xdg_output_v1_name,
    .description = PQCWAYLAND_handle_xdg_output_v1_description,
};

static void PQCWAYLAND_add_xdg_output_v1_info(struct PQCWAYLAND_xdg_output_manager_v1_info *manager_info, struct PQCWAYLAND_output_info *output) {
    struct PQCWAYLAND_xdg_output_v1_info *xdg_output = static_cast<PQCWAYLAND_xdg_output_v1_info*>(calloc(1, sizeof *xdg_output));

    wl_list_insert(&manager_info->outputs, &xdg_output->link);
    xdg_output->xdg_output = zxdg_output_manager_v1_get_xdg_output(
        manager_info->manager, output->output);
    zxdg_output_v1_add_listener(xdg_output->xdg_output,
        &xdg_output_v1_listener, xdg_output);

    xdg_output->output = output;

    manager_info->info->roundtrip_needed = true;
}

static void PQCWAYLAND_add_xdg_output_manager_v1_info(struct PQCWAYLAND_wayland_info *info, uint32_t id, uint32_t version) {
    struct PQCWAYLAND_output_info *output;
    struct PQCWAYLAND_xdg_output_manager_v1_info *manager = static_cast<PQCWAYLAND_xdg_output_manager_v1_info*>(calloc(1, sizeof *manager));

    wl_list_init(&manager->outputs);
    manager->info = info;

    PQCWAYLAND_init_global_info(info, &manager->global, id,
        zxdg_output_manager_v1_interface.name, version);
    manager->global.collect = PQCWAYLAND_collect_xdg_output_manager_v1_info;
    manager->global.destroy = PQCWAYLAND_destroy_xdg_output_manager_v1_info;

    manager->manager = static_cast<zxdg_output_manager_v1*>(wl_registry_bind(info->registry, id,
        &zxdg_output_manager_v1_interface, version > 2 ? 2 : version));

    wl_list_for_each(output, &info->outputs, global_link)
        PQCWAYLAND_add_xdg_output_v1_info(manager, output);

    info->xdg_output_manager_v1_info = manager;
}

static void PQCWAYLAND_output_handle_geometry(void *data, struct wl_output *wl_output, int32_t x, int32_t y, int32_t physical_width, int32_t physical_height, int32_t subpixel, const char *make, const char *model, int32_t output_transform) {}

static void PQCWAYLAND_output_handle_mode(void *data, struct wl_output *wl_output, uint32_t flags, int32_t width, int32_t height, int32_t refresh) {
    struct PQCWAYLAND_output_info *output = static_cast<PQCWAYLAND_output_info*>(data);
    output->actual_width = width;
}

static void PQCWAYLAND_output_handle_done(void *data, struct wl_output *wl_output) {}

static void PQCWAYLAND_output_handle_scale(void *data, struct wl_output *wl_output, int32_t scale) {}

static void PQCWAYLAND_output_handle_name(void *data, struct wl_output *wl_output, const char *name) {
    struct PQCWAYLAND_output_info *output = static_cast<PQCWAYLAND_output_info*>(data);
    output->model_name = name;
}

static void PQCWAYLAND_output_handle_description(void *data, struct wl_output *wl_output, const char *description) {}

static const struct wl_output_listener output_listener = {
    PQCWAYLAND_output_handle_geometry,
    PQCWAYLAND_output_handle_mode,
    PQCWAYLAND_output_handle_done,
    PQCWAYLAND_output_handle_scale,
    PQCWAYLAND_output_handle_name,
    PQCWAYLAND_output_handle_description,
};

static void PQCWAYLAND_destroy_output_info(void *data) {
    struct PQCWAYLAND_output_info *output = static_cast<PQCWAYLAND_output_info*>(data);
    wl_output_destroy(output->output);
}

static void PQCWAYLAND_add_output_info(struct PQCWAYLAND_wayland_info *info, int id, int version) {
    struct PQCWAYLAND_output_info *output = static_cast<PQCWAYLAND_output_info*>(calloc(1, sizeof *output));

    PQCWAYLAND_init_global_info(info, &output->global, id, "wl_output", version);
    output->global.collect = PQCWAYLAND_collect_output_info;
    output->global.destroy = PQCWAYLAND_destroy_output_info;

    output->version = std::min(version, 4);

    output->output = static_cast<wl_output*>(wl_registry_bind(info->registry, id,
                    &wl_output_interface, output->version));
    wl_output_add_listener(output->output, &output_listener,
                output);

    info->roundtrip_needed = true;
    wl_list_insert(&info->outputs, &output->global_link);

    if (info->xdg_output_manager_v1_info)
        PQCWAYLAND_add_xdg_output_v1_info(info->xdg_output_manager_v1_info,
                    output);
}

static void PQCWAYLAND_destroy_global_info(void *info) {}

static void PQCWAYLAND_global_handler(void *data, struct wl_registry *registry, uint32_t id, const char *interface, uint32_t version) {

    struct PQCWAYLAND_wayland_info *info = static_cast<PQCWAYLAND_wayland_info*>(data);

    if (!strcmp(interface, "wl_output"))
        PQCWAYLAND_add_output_info(info, id, version);
    else if (!strcmp(interface, zxdg_output_manager_v1_interface.name))
        PQCWAYLAND_add_xdg_output_manager_v1_info(info, id, version);
}

static void PQCWAYLAND_global_remove_handler(void *data, struct wl_registry *registry, uint32_t name) {}

static const struct wl_registry_listener registry_listener = {
    PQCWAYLAND_global_handler,
    PQCWAYLAND_global_remove_handler
};

static void PQCWAYLAND_collect_infos(struct PQCWAYLAND_wayland_info *wayland_info) {

    struct wl_list *infos = &wayland_info->infos;
    struct PQCWAYLAND_wayland_global_info *info;

    wl_list_for_each(info, infos, link) {
        info->collect(info);
    }
}

static void PQCWAYLAND_destroy_infos(struct wl_list *infos) {
    struct PQCWAYLAND_wayland_global_info *info, *tmp;
    wl_list_for_each_safe(info, tmp, infos, link) {
        info->destroy(info);
        wl_list_remove(&info->link);
        free(info);
    }
}

QVariantMap get_device_pixel_ratios() {

    QVariantMap ret;

    struct PQCWAYLAND_wayland_info info;

    info.display = wl_display_connect(NULL);
    if(!info.display) {
        qWarning() << "failed to create display:" << strerror(errno);
        return ret;
    }

    info.xdg_output_manager_v1_info = NULL;
    wl_list_init(&info.infos);
    wl_list_init(&info.outputs);

    info.registry = wl_display_get_registry(info.display);
    wl_registry_add_listener(info.registry, &registry_listener, &info);

    do {
        info.roundtrip_needed = false;
        wl_display_roundtrip(info.display);
    } while (info.roundtrip_needed);

    PQCWAYLAND_collect_infos(&info);

    QMap<int, QString> id2String;

    for(const auto& [key, value] : PQCWAYLAND_final_screens) {
        id2String[value] = QString::fromStdString(key);
    }

    for(const auto& [key, value] : PQCWAYLAND_final_data) {
        if(value[0] > 0) {
            float rat = static_cast<float>(value[1])/static_cast<float>(value[0]);
            ret.insert(id2String[key], rat);
            if(std::abs(rat) < 1e-4)
                ret[id2String[key]] = 1.0;
        }
    }

    PQCWAYLAND_destroy_infos(&info.infos);

    wl_registry_destroy(info.registry);
    wl_display_disconnect(info.display);

    return ret;

}

QVariantMap PQCWayland::getDevicePixelRatio() {
    return get_device_pixel_ratios();
}

#endif
