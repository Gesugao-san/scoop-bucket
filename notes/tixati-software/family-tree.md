# Tixati family tree

Lineage of Tixati and its relatives, layered by protocols, networks and developers.
Protocols and networks are grouped by code openness; developers are not — their works carry the tags.

Legend: `[O]` open source · `[C]` closed source · `[?]` unverified.
Years for programs and organizations: start–end. Years for people: birth–death, `b.` for living; `mentioned` — first–last dated mention on Wikipedia when no birth date is given.
Linked names lead to the English Wikipedia article via enwp.org.

protocols/\
├ closed/\
│ ├ [Napster][wp-napster] protocol (1999) — no public spec\
│ │ └ OpenNap (see open/)\
│ ├ WPNP — WinMX Peer Network Protocol (2001–present) — versions 3.31, 3.53\
│ │ ├ [WinMX][wp-winmx] (2000–2005) [C]\
│ │ ├ WinPY (2008) [O]\
│ │ └ wpnchatd (?–2013) [O]\
│ └ [Fopnu][wp-fopnu] protocol (2017–present) — pure UDP with forward error correction\
│   └ [Fopnu][wp-fopnu] (2017–present) [C]\
└ open/\
  ├ [OpenNap][wp-opennap] (1999–2001) [GPL] — reverse-engineered Napster protocol;\
  │ │   any file type, server linking\
  │ └ [WinMX][wp-winmx] OpenNap client mode (2000–present) [C]\
  ├ [BitTorrent][wp-bittorrent] (2001–present)\
  │ ├ [BitTorrent client][wp-bittorrent_(software)] (2001–present) — [O] until 5.30, [C] since 6.0 (2007)\
  │ └ [Tixati][wp-tixati] (2009–present) [C] — BitTorrent v2 (BEP-52) since v3.11\
  ├ [Tor][wp-tor_(network)] (2002–present) [BSD-3]\
  │ └ [DarkMX][wp-darkmx] (2021–present) [C]\
  └ [I2P][wp-i2p] (2003–present) [public domain, BSD, GPL, MIT]\
    ├ [Tixati][wp-tixati] (2025–present) [C] — external router over I2CP; I2P DHT and PEX\
    └ [DarkMX][wp-darkmx] (2025–present) [C] — external router over I2CP;\
      replaces Tor link when both peers enable it

networks/\
├ closed/\
│ ├ [Napster][wp-napster] (1999–2001) — centralized\
│ ├ WPN — WinMX Peer Network (2001–present)\
│ │ ├ Frontcode peer caches (2001–2005)\
│ │ ├ community peer caches (2005–present)\
│ │ │ ├ DNS patches (2005)\
│ │ │ ├ winmxgroup caches by KingMacro (?–2007)\
│ │ │ └ WinMX Community Patch (2008)\
│ │ └ clients\
│ │   ├ [WinMX][wp-winmx] (2000–2005) [C]\
│ │   ├ OurMx (2013–?) [?]\
│ │   ├ WinPY (2008) [O]\
│ │   └ wpnchatd — chat daemon (?–2013) [O]\
│ ├ Tixati channels (?–present) — chat, private messages, encrypted forum\
│ └ [Fopnu][wp-fopnu] network (2017–present) — fully decentralized, local indexing,\
│     no search relaying, recirculating upload tokens, encryption with decentralized PKI\
└ open/\
  ├ [OpenNap][wp-opennap] (1999–present) — server swarm\
  │ └ [WinMX][wp-winmx] (2000–present) [C]\
  ├ [BitTorrent][wp-bittorrent] swarms (2001–present) — trackers, DHT, PEX; clearnet and I2P\
  │ └ [Tixati][wp-tixati] (2009–present) [C] — Windows, Linux, Android (2024–present)\
  ├ [Tor][wp-tor_(network)] (2002–present)\
  │ └ [DarkMX][wp-darkmx] (2021–present) [C] — Windows, Linux, Android (2023–present);\
  │     user-hosted file indexes on onion services\
  └ [I2P][wp-i2p] (2003–present)\
    ├ [Tixati][wp-tixati] (2025–present) [C]\
    └ [DarkMX][wp-darkmx] (2025–present) [C]

developers/\
├ people/\
│ ├ [Shawn Fanning][wp-shawn_fanning] (mentioned 1999–2014)\
│ │ └ [Napster][wp-napster] (1999–2001) [C]\
│ ├ [Sean Parker][wp-sean_parker] (b. 1979)\
│ │ └ [Napster][wp-napster] (1999–2001) [C], co-founder\
│ ├ Drscholl (?)\
│ │ └ [OpenNap][wp-opennap] (1999–2001) [O]\
│ ├ [Bram Cohen][wp-bram_cohen] (b. 1975)\
│ │ ├ [BitTorrent][wp-bittorrent] protocol (2001–present) [O]\
│ │ ├ [BitTorrent client][wp-bittorrent_(software)] (2001–present) — [O] until 5.30, [C] since 6.0 (2007)\
│ │ └ [BitTorrent, Inc.][wp-bittorrent_(company)] (2004–present), co-founder\
│ ├ [Ashwin Navin][wp-ashwin_navin] (b. c. 1977)\
│ │ └ [BitTorrent, Inc.][wp-bittorrent_(company)] (2004–present), co-founder\
│ ├ Kevin Hearn (mentioned 2000–2021) — no own article; not the Barenaked Ladies musician\
│ │ ├ [Frontcode Technologies][wp-frontcode_technologies] (?–2005)\
│ │ └ Tixati Software Inc. (?–present)\
│ ├ KingMacro (not on Wikipedia)\
│ │ └ winmxgroup dll and peer caches (?–2007) [?]\
│ └ ranma42 (not on Wikipedia)\
│   └ wpnchatd (?–2013) [O]\
└ organizations/\
  ├ [Napster][wp-napster] (1999–2001; brand 2002–present, AI tool since 2026)\
  │ └ Napster client and servers (1999–2001) [C]\
  ├ [BitTorrent, Inc.][wp-bittorrent_(company)] (2004–present; Rainberry, Inc. since 2018)\
  │ └ [BitTorrent client][wp-bittorrent_(software)] — [O] 4.x–5.30, [C] since 6.0 (2007)\
  ├ [The Tor Project][wp-the_tor_project] (2006–present)\
  │ └ [Tor][wp-tor_(network)] (2002–present) [O]\
  ├ [Frontcode Technologies][wp-frontcode_technologies] (?–2005)\
  │ ├ [WinMX][wp-winmx] (2000–2005) [C]\
  │ └ WPNP / WPN (2001–2005) [C]\
  ├ Tixati Software Inc. (?–present)\
  │ ├ [Tixati][wp-tixati] (2009–present) [C]\
  │ │ └ Tixati Android (2024–present) [C]\
  │ ├ [Fopnu][wp-fopnu] (2017–present) [C]\
  │ ├ [DarkMX][wp-darkmx] (2021–present) [C]\
  │ └ Super Simple Server (?–present) [C]\
  └ WinMX community (2005–present)\
    ├ patch authors → DNS patches (2005), Community Patch (2008) [?]\
    ├ OurMx team → OurMx (2013–?) [?]\
    └ WinPY project → WinPY (2008) [O]

## Sources

- [Napster — Wikipedia][wp-napster]
- [WinMX — Wikipedia][wp-winmx]
- [Fopnu — Wikipedia][wp-fopnu]
- [OpenNap — Wikipedia][wp-opennap]
- [BitTorrent — Wikipedia][wp-bittorrent]
- [BitTorrent (software) — Wikipedia][wp-bittorrent_(software)]
- [Tixati — Wikipedia][wp-tixati]
- [Tor (network) — Wikipedia][wp-tor_(network)]
- [DarkMX — Wikipedia][wp-darkmx]
- [I2P — Wikipedia][wp-i2p]
- [Shawn Fanning — Wikipedia][wp-shawn_fanning]
- [Sean Parker — Wikipedia][wp-sean_parker]
- [Bram Cohen — Wikipedia][wp-bram_cohen]
- [BitTorrent (company) — Wikipedia][wp-bittorrent_(company)]
- [Ashwin Navin — Wikipedia][wp-ashwin_navin]
- [Frontcode Technologies — Wikipedia][wp-frontcode_technologies]
- [The Tor Project — Wikipedia][wp-the_tor_project]
- [Tixati — news][tixati-news]
- [Tixati — Android][tixati-android]
- [Tixati — I2P][tixati-i2p]
- [Fopnu][fopnu-site]
- [Fopnu — news][fopnu-news]
- [DarkMX][darkmx-site]
- [DarkMX — news][darkmx-news]
- [DarkMX — I2P][darkmx-i2p]
- [DarkMX forum — I2P][darkmx-forum-i2p]
- [Super Simple Server][sss-site]
- [WinPY — SourceForge][winpy-sf]
- [wpnchatd — SourceForge][wpnchatd-sf]

[wp-napster]: https://enwp.org/Napster "Napster — Wikipedia"
[wp-winmx]: https://enwp.org/WinMX "WinMX — Wikipedia"
[wp-fopnu]: https://enwp.org/Fopnu "Fopnu — Wikipedia"
[wp-opennap]: https://enwp.org/OpenNap "OpenNap — Wikipedia"
[wp-bittorrent]: https://enwp.org/BitTorrent "BitTorrent — Wikipedia"
[wp-bittorrent_(software)]: https://enwp.org/BitTorrent_(software) "BitTorrent (software) — Wikipedia"
[wp-tixati]: https://enwp.org/Tixati "Tixati — Wikipedia"
[wp-tor_(network)]: https://enwp.org/Tor_(network) "Tor (network) — Wikipedia"
[wp-darkmx]: https://enwp.org/DarkMX "DarkMX — Wikipedia"
[wp-i2p]: https://enwp.org/I2P "I2P — Wikipedia"
[wp-shawn_fanning]: https://enwp.org/Shawn_Fanning "Shawn Fanning — Wikipedia"
[wp-sean_parker]: https://enwp.org/Sean_Parker "Sean Parker — Wikipedia"
[wp-bram_cohen]: https://enwp.org/Bram_Cohen "Bram Cohen — Wikipedia"
[wp-bittorrent_(company)]: https://enwp.org/BitTorrent_(company) "BitTorrent (company) — Wikipedia"
[wp-ashwin_navin]: https://enwp.org/Ashwin_Navin "Ashwin Navin — Wikipedia"
[wp-frontcode_technologies]: https://enwp.org/Frontcode_Technologies "Frontcode Technologies — Wikipedia"
[wp-the_tor_project]: https://enwp.org/The_Tor_Project "The Tor Project — Wikipedia"
[tixati-news]: https://www.tixati.com/news "Tixati — news"
[tixati-android]: https://www.tixati.com/android "Tixati — Android"
[tixati-i2p]: https://support.tixati.com/i2p "Tixati — I2P"
[fopnu-site]: https://www.fopnu.com/ "Fopnu"
[fopnu-news]: https://www.fopnu.com/news "Fopnu — news"
[darkmx-site]: https://darkmx.app/ "DarkMX"
[darkmx-news]: https://darkmx.app/news "DarkMX — news"
[darkmx-i2p]: https://darkmx.app/i2p "DarkMX — I2P"
[darkmx-forum-i2p]: https://darkmx.app/forum/94 "DarkMX forum — I2P"
[sss-site]: https://www.supersimpleserver.com/ "Super Simple Server"
[winpy-sf]: https://sourceforge.net/projects/winpy/files/ "WinPY — SourceForge"
[wpnchatd-sf]: https://sourceforge.net/p/wpnchatd/ "wpnchatd — SourceForge"
