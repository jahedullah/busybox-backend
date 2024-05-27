package com.jahedul.busybox_backend.service;

import java.util.List;
import java.util.Optional;

import lombok.RequiredArgsConstructor;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.jahedul.busybox_backend.entity.Task;
import com.jahedul.busybox_backend.repository.TaskRepository;

@Service
@RequiredArgsConstructor
public class TaskService {

  private final TaskRepository taskRepository;

  public List<Task> findAllTasks() {
    return taskRepository.findAll();
  }

  public Task createTask(Task task) {
    return taskRepository.save(task);
  }

  public Optional<Task> findTaskById(Long id) {
    return taskRepository.findById(id);
  }
}