<template>
  <div id="app">
    <section v-for="(tasks, month) in task_list">
      <h2>{{month}}</h2>
      <ul>
        <li v-for="task in tasks">
          <div>{{task.date}} : {{task.title}}</div>
        </li>
      </ul>
    </section>
  </div>
</template>

<script>
export default {
  data: function () {
    return {
      task_list: {
        '2018/09': [
          {
            date: 10,
            title: 'task3'
          },
          {
            date: 1,
            title: 'task2'
          },
        ],
        '2018/08': [
          {
            date: 10,
            title: 'task1'
          },
        ]
      }
    }
  },
  mounted () {
    axios
      .get('/tasks/task_list')
      .then(response => (this.task_list = response))
  }
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
