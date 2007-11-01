From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 14:26:10 +0000
Subject: DCCP and GStreamer: File descriptor sharing
Message-Id: <5bc4c4570711010726h5580c72dt59748c57be50b064@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi all,
   I want to share a same socket-fd between two process using dccp.
The gstreamer plugin architecture uses a concept of sink and src (each
one named element), where sink send and src receive data. In this
case, one of then connects and inform the file descriptor to the
other. Then I thought that if I just share the socket_fd the things
will work, but it didn't. I need something like this:

On dccp_server_sink_element:

1 - sock_fd = socket(...);  // sock_id = 10 (for instance), sink tell
dccp_server_src_element this value
2 - bind(sock_fd);
3 - listen(sock_fd);

On dccp_server_src_element:

1 - sock_fd = 10 // for the first version I will just pass this value
via set property, but after I will use unix_socket (as suggested by
Arnaldo) to communicate both elements
2 - wrote = send(sock_fd, ...);

In the client side (similar to server side:

On dccp_client_sink_element:

1 - sock_fd = socket(...);  // sock_id = 5 (for instance)
2 - connect(sock_fd);
3 - send(sock_fd);

On dccp_client_src_element:

1 - read(sock_fd) // passed by dccp_client_sink_element.

Is there any additional manipulation to enable the sock_fd sharing.
The error show is "Invalid File Descriptor" when I try to use it in
the srcs elements.

Thanks,

Leandro.
