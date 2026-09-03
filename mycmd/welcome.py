#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""打开终端自动问好：时间问候 + 日期 + 节日 + 天气 + 格言"""

import datetime
import os
import random
import subprocess
import sys

USER = os.environ.get("USER", "朋友")
TODAY = datetime.date.today()


# ===== 问好（根据时间） =====
def greet():
    h = datetime.datetime.now().hour
    if h < 6:
        return "凌晨好 🌙"
    elif h < 12:
        return "早上好 ☀️"
    elif h < 14:
        return "中午好 🍱"
    elif h < 18:
        return "下午好 🍵"
    else:
        return "晚上好 🌆"


WEEKDAYS = ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"]


# ===== 节日（公历） =====
SOLAR_FESTIVALS = {
    (1, 1):  "元旦 🎉",
    (2, 14): "情人节 💝",
    (3, 8):  "妇女节 🌸",
    (4, 1):  "愚人节 🃏",
    (5, 1):  "劳动节 🛠",
    (5, 4):  "青年节 ⚡",
    (6, 1):  "儿童节 🧸",
    (8, 1):  "建军节 🎖",
    (9, 10): "教师节 🍎",
    (10, 1): "国庆节 🇨🇳",
    (12, 24): "平安夜 🎅",
    (12, 25): "圣诞节 🎄",
}


def festivals():
    """返回节日列表（含农历节日，需 lunarcalendar，可缺省）"""
    result = []
    md = (TODAY.month, TODAY.day)
    if md in SOLAR_FESTIVALS:
        result.append(SOLAR_FESTIVALS[md])

    # 农历节日（可选：pip install lunarcalendar）
    try:
        from lunarcalendar import Converter
        lunar = Converter.Solar2Lunar(TODAY)
        lunar_fests = {
            (1, 1):  "春节 🧨",
            (1, 15): "元宵节 🏮",
            (5, 5):  "端午节 🚣",
            (7, 7):  "七夕 💘",
            (8, 15): "中秋节 🥮",
            (9, 9):  "重阳节 ⛰",
            (12, 8): "腊八节 🥣",
            (12, 30): "除夕 🧨",
            (12, 29): "除夕(小月) 🧨",
        }
        lm = (lunar.month, lunar.day)
        if lm in lunar_fests:
            result.append(lunar_fests[lm])
    except ImportError:
        pass
    return result


# ===== 天气（wttr.in 免费服务，可换城市） =====
def weather(city="Beijing"):
    try:
        out = subprocess.run(
            ["curl", "-s", "--max-time", "3",
             f"wttr.in/{city}?format=%c+%t+湿度%h+风力%f"],
            capture_output=True, text=True, timeout=5)
        if out.returncode == 0 and out.stdout.strip():
            return out.stdout.strip()
    except Exception:
        pass
    return "获取失败（无网络或超时）"


# ===== 随机格言 =====
QUOTES = [
    "今天也要加油鸭！🦆",
    "代码写完了吗？bug 修完了吗？",
    "记得多喝水 💧",
    "站起来活动一下，别久坐～",
    "少刷手机，多写代码 😄",
    "今天也是元气满满的一天！",
]


def main():
    # 每天只显示一次（想每次都显示就删掉这3行）
#    stamp = f"/tmp/.welcome_{TODAY.strftime('%Y%m%d')}"
#    if os.path.exists(stamp):
#        sys.exit(0)
#    with open(stamp, "w") as f:
#        f.write("ok")

    line = "=" * 50
    print(line)
    now = datetime.datetime.now()
    print(f"{greet()}，{USER}！今天是 "
          f"{TODAY.year}年{TODAY.month}月{TODAY.day}日 "
          f"{WEEKDAYS[TODAY.weekday()]}")
    print()
    print(f"⏰  现在时间：{now.strftime('%H:%M:%S')}")
    print()
    fests = festivals()
    if fests:
        print(f"🎊  今天是节日：{'、'.join(fests)}")
    else:
        print(f"📅  今日无节日，平凡而美好的一天")
    print()
    print(f"🌤   天气：{weather('Hangzhou')}")
    print()
    print(f"💬  {random.choice(QUOTES)}")
    print(line)


if __name__ == "__main__":
    main()

