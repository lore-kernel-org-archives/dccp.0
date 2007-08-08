From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 08 Aug 2007 12:31:50 +0000
Subject: DCCP Socket Programming Library with 9 client/server apps
Message-Id: <200708081331.50888@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have uploaded a DCCP socket programming library to support DCCP userland applications on

	http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps

It takes care of many low-level details, such as making getaddrinfo() work for DCCP v4 and v6, 
assigning, parsing, and decoding service codes; use of partial checksums and more.

It comes with 9 example client/server programs:
 * Echo / Discard / Chargen / Time / Daytime
 * Hello world example with SO_LINGER and normal
 * Steven's sock program (see below) for v4/v6 DCCP/UDP-Lite
 * ttcp for v4/v6 DCCP/UDP-Lite

All applications and the library have been tested to work on both i386 and sparc64 (little/big endian).
Some are useful for DCCP testing - the Chargen for example uses random buffer sizes which are useful
for stress-testing. 

The library provides many low-level routines which may also be of use outside the library,
i.e. it is not necessary to build all applications specifically with such a library.

Documentation is at http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/dccplib.html
It can be downloaded from http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/dccp_applications_lib.tar.gz

An example live transcript of Stevens' sock program linked against the library:

root@motz $ sock -dSC:KOTZ,SC=xC0DE -is 2000
	IPv4/IPv6 DCCP socket listening on ::#2000
	DCCP service codes: SC:KOTZ, SC=xC0DE
	accept from from ::ffff:139.133.209.103#45108
	buffer read #1: 1024 bytes
	... (998 lines deleted)
	buffer read #1000: 1024 bytes
	Received a total of 1024000 bytes in 1000 buffer reads.


... and here is a fully functional Daytime IPv4 / IPv6 client for DCCP:

int main(int argc, char **argv)
{
        char    buf[BUFSIZ];
        int     sockfd, cnt;

        if (argc != 2)
                err_quit("%s: Need a `host' argument", *argv);

        sockfd = dccp_connect_simple(argv[1], "SC:DTIM");

        if ((cnt = read(sockfd, buf, sizeof(buf))) < 0)
                err_sys("read error");

        return write(2, buf, cnt) > 0;
}
