package com.jahedul.busybox_backend.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.jahedul.busybox_backend.constants.Url;

@RestController
@RequestMapping(value = Url.API_V1)
public class BusyBoxController {

  @GetMapping(value = Url.PING)
  public String pingBusyBox() {
    return "Hello from Busy box";
  }
}
