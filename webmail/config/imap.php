<?php

$config['imap_conn_options'] = array(
    'ssl' => array(
      'verify_peer'       => true,
      'allow_self_signed' => true,
      'peer_name'         => getenv('TLS_PEER_NAME'),
      'ciphers'           => 'TLSv1+HIGH:!aNull:@STRENGTH',
      'cafile'            => getenv('TLS_CERT_PATH'),
    ),
);
