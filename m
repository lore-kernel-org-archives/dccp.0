From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Date: Thu, 22 Nov 2007 12:47:05 +0000
Subject: Re: Test tree patch inventory - update: batch 5
Message-Id: <20071122124704.GC17441@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20071121185122.GJ24995@ghostprotocols.net>
In-Reply-To: <20071121185122.GJ24995@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Sat, Nov 17, 2007 at 03:42:52PM +0000, Gerrit Renker escreveu:
> 
> 6. Support for aborting the connection (like in TCP)
> ---------------------------------------------------	
> The next logically separate set involves the `abort' function (i.e. killing the connection
> when there is unread data, abnormal termination), this set only has two patches:
> 
> 	[DCCP]: Check for unread data on close

Applied.

> 	[DCCP]: Add support for abortive release

Applied.

- Arnaldo
