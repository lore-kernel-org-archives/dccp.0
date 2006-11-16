From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 16 Nov 2006 17:12:34 +0000
Subject: Re: message scheme / Unload Hack
Message-Id: <200611161712.35070@strip-the-willow>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_DwJXFFY6duonpmP"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--Boundary-00=_DwJXFFY6duonpmP
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

|  Using a DCCP_ prefix for BUG(), BUG_ON(), WARN_ON() and a new WARN()
|  with the difference being none would panic the machine, but warn, in
|  some cases ratelimited, seems to be the way to go, later, as you
|  suggests, we just remove the prefix.
I will take this into consideration and work on that until tomorrow.

  
|  > For the moment, as Ian has pointed out, bringing the machine to a grinding halt for every little
|  > problem is probably too much of a nuisance (in the same vein, I would really like to suggest the
|  > return of Unload Hack :0).
|  
|  I'll look at what to do to avoid allowing the removal while there are
|  TW sockets on the death row :-)
I had meant to look into what David said about socket references, but my knowledge of module internals
is probably not so great (but intended to catch up on this).
Currently all modules have to be ejected in some order (ccids ->  dccp_ipv6 -> dccp_ipv4 -> dccp); 
I attach the script which I am using for unloading, this doesn't solve the Unload Hack, but has been useful. 

Gerrit



--Boundary-00=_DwJXFFY6duonpmP
Content-Type: application/x-perl;
  name="dccp_module_unload_script.pl"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="dccp_module_unload_script.pl"

#!/usr/bin/perl
# 
# Script to unload DCCP modules (e.g. after compiling new ones)

@ARGV = qw#/proc/modules#;

# create a topological order among the modules
# the `dccp' module comes last, after dccp_ipv4, dccp_ipv6, ...
sub by_dependency {
	return ($a !~ m#(ccid|ipv6|ipv4|dccp)#);
}

while(<>) { push(@module_list, $1) if (m#^(dccp\S*)\s+#) }

for (sort by_dependency @module_list) {
	system "rmmod -v $_ " .  ((m#ipv#)? "-f" : "");
	$? == 0 || die "some problems unloading $_\n";
}

--Boundary-00=_DwJXFFY6duonpmP--
