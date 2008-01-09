From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 09 Jan 2008 12:28:27 +0000
Subject: Re: FW:  ccid2/ccid3 oopses
Message-Id: <20080109122827.GC4461@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <93680347@web.de>
In-Reply-To: <93680347@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Roland, -

>> apparently, i got crashes when loading/unloading other driver modules just
>> after ccid2 or ccid3 had been loaded/unloaded _once_ (have not used them at
>> all, just modprobe module;modprobe -r module) >
>> 
<snip>
>> the easiest way to reproduce is:
>> 
>> while true;do modprobe dccp_ccid2/3;modprobe -r dccp_ccid2/3;done
>> after short time, the kernel oopses (messages below)
>> 
>> i`m not sure if this is worth to be filed at kernel bugzilla, so i`m contacting
>> you personally first.
>>
The issue is known: once loaded, the DCCP modules can not be unloaded
without causing a crash as the one you have observed. This is due to the
fact that dccp_ipv{4,6} use control sockets which need to be released
before the module can be unloaded.
When the control sockets are not released then crashes will always
result.
In earlier versions of DCCP there was a kernel option known as "unload hack",
which conditionally inserted 
	sock_release(dccp_v{4,6}_ctl_socket);
in 
	dccp_v{4,6}_exit()

However, as the name says, it is a hack since there are other issues to 
be considered:
	* sockets in timewait state
	* other wait states (e.g. half-open connections)
	* memory which has not been released
	* module dependencies

With regard to the latter, I am normally using the Unload Hack and
release modules in the following order:

	dccp_probe => dccp_ccid2 => dccp_ccid3 => dccp_tfrc_lib =>
        dccp_ipv6  => dccp_ipv4  => dccp_diag  => dccp

Long story short
 * the CCID/DCCP modules can currently not safely be unloaded
 * maybe we should disable module unloading for the mainline kernel
 * if anyone is interested to use the unload hack, here is the old patch
   http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/Unload_Hack.diff

Please feel free to come back on this issue
Gerrit
