From: <burakgmail-dccp@yahoo.com>
Date: Fri, 18 Aug 2006 16:20:12 +0000
Subject: Re: [BUG] CCID3 - loss not detected if in order
Message-Id: <20060818162012.19346.qmail@web30001.mail.mud.yahoo.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00607201930k6650084oc75a868a6011a525@mail.gmail.com>
In-Reply-To: <5640c7e00607201930k6650084oc75a868a6011a525@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi again,

Made more tests. Recompiled the kernel with lossfix and ccid3li patches only, but no difference. The receiver freezes. Below is the /var/log/messages related with the problem  on the receiver box.

Aug 18 18:52:16 thinkpad gconfd (burakgo-10474): starting (version 2.14.0), pid 10474 user 'burakgo'
Aug 18 18:52:16 thinkpad gconfd (burakgo-10474): Resolved address "xml:readonly:/etc/gconf/gconf.xml.mandatory" to a read-only configuration source at position 0
Aug 18 18:52:16 thinkpad gconfd (burakgo-10474): Resolved address "xml:readwrite:/home/burakgo/.gconf" to a writable configuration source at position 1
Aug 18 18:52:16 thinkpad gconfd (burakgo-10474): Resolved address "xml:readonly:/etc/gconf/gconf.xml.defaults" to a read-only configuration source at position 2
Aug 18 18:52:18 thinkpad gconfd (burakgo-10474): Resolved address "xml:readwrite:/home/burakgo/.gconf" to a writable configuration source at position 0
Aug 18 18:54:51 thinkpad kernel: ccid3_debug is 0
Aug 18 18:54:51 thinkpad kernel: CCID: Registered CCID 3 (ccid3)
Aug 18 18:57:18 thinkpad kernel: start pinv = 0
Aug 18 18:57:18 thinkpad kernel: TFRC_SSTATE_NO_SENT warn
Aug 18 18:57:18 thinkpad kernel: ccid3_hc_rx_detect_loss packet 11679865163, old 0
Aug 18 18:57:18 thinkpad kernel: ccid3_hc_rx_detect_loss - not loss
Aug 18 18:57:18 thinkpad kernel: start pinv = 0
Aug 18 18:57:18 thinkpad kernel: TFRC_SSTATE_NO_SENT warn
Aug 18 18:57:18 thinkpad kernel: ccid3_hc_rx_detect_loss packet 11679865164, old 11679865163
Aug 18 18:57:18 thinkpad kernel: start pinv = 0
Aug 18 18:57:18 thinkpad kernel: TFRC_SSTATE_NO_SENT warn
Aug 18 18:57:19 thinkpad kernel: ccid3_hc_rx_detect_loss packet 11679865165, old 11679865163
Aug 18 18:57:19 thinkpad kernel: start pinv = 0
Aug 18 18:57:19 thinkpad kernel: TFRC_SSTATE_NO_SENT warn
Aug 18 18:57:19 thinkpad kernel: ccid3_hc_rx_detect_loss packet 11679865166, old 11679865163
Aug 18 18:57:19 thinkpad kernel: start pinv = 0
Aug 18 18:57:19 thinkpad kernel: TFRC_SSTATE_NO_SENT warn
Aug 18 19:01:01 thinkpad syslogd 1.4.1: restart.
Aug 18 19:01:02 thinkpad kernel: klogd 1.4.1, log source = /proc/kmsg started.
Aug 18 19:01:02 thinkpad kernel: Linux version 2.6.18-rc3-ian (root@localhost.localdomain) (gcc version 4.1.1 20060525 (Red Hat 4.1.1-1)) #1 Fri Aug 18 11:31:08 EEST 2006
Aug 18 19:01:02 thinkpad kernel: BIOS-provided physical RAM map:
Aug 18 19:01:02 thinkpad kernel:  BIOS-e820: 0000000000000000 - 000000000009f000 (usable)
Aug 18 19:01:02 thinkpad kernel:  BIOS-e820: 000000000009f000 - 00000000000a0000 (reserved)
Aug 18 19:01:02 thinkpad kernel:  BIOS-e820: 00000000000d0000 - 00000000000d4000 (reserved)
Aug 18 19:01:02 thinkpad kernel:  BIOS-e820: 00000000000dc000 - 0000000000100000 (reserved)

-- Burak

----- Original Message ----
From: burakgmail-dccp@yahoo.com
To: dccp@vger.kernel.org
Sent: Friday, August 18, 2006 4:15:53 PM
Subject: Re: [BUG] CCID3 - loss not detected if in order

Hi Ian, 
 
I had been trying to get a "p" value other than zero from some days, and I was relieved when I read your post yesterday. 
 
So I applied your lossfix and ccid3li patches (and all the other patches in http://wand.net.nz/~iam4/dccp/patches/ actually) to my linux boxes (both sender&receiver) and started some testing. However, the linux box at the receiver side (scenario: sending data from sender to receiver) got freezed everytime I played the scenario and I had to switch off/on the machine to get it back to life. There seems to be a problem related with the patches I applied, maybe txbuff patch. Do you have any idea? 
 
Burak Gorkemli
Ph.D. Candidate
Koc University
Turkey
 


-
To unsubscribe from this list: send the line "unsubscribe dccp" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html



