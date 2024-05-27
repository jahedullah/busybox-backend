package com.jahedul.busybox_backend.controller;

import java.net.URI;
import java.util.List;

import lombok.RequiredArgsConstructor;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.jahedul.busybox_backend.constants.Url;
import com.jahedul.busybox_backend.entity.Task;
import com.jahedul.busybox_backend.service.TaskService;

@RestController
@RequestMapping(value = Url.API_V1)
@RequiredArgsConstructor
public class TaskController {

  private final TaskService taskService;

  @GetMapping(value = "/tasks")
  public ResponseEntity<List<Task>> getTasks() {
    List<Task> tasks = taskService.findAllTasks();

    return ResponseEntity.ok(tasks);
  }

  @PostMapping(value = "/tasks")
  public ResponseEntity<Task> createTask(@RequestBody Task task) {
    Task createdTask = taskService.createTask(task);
    return ResponseEntity.created(URI.create("/tasks/" + createdTask.getId())).body(createdTask);
  }
}
