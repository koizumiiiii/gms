<template>
  <div id="app">
    <section v-if="new_task.visible" class="add_new_task_wrapper getHeight">
      <div class="add_new_task_inner">
        <div class="add_new_task_inner__btn_area">
          <button id="btn_cancel" v-on:click="cancel_new_task" type="button">×</button>
          <button id="btn_add" v-on:click="add_new_task" type="button">add</button>
        </div>
        <div class="add_new_task_inner__input_area">
          <input v-model="new_task.title" type="text" name="title" placeholder="タスクタイトル" />
          <input v-model="new_task.start_at" type="datetime-local" name="start_at"/>
          <textarea v-model="new_task.detail" placeholder="メモ" class="" rows="4" cols="40" /></textarea>
        </div>
      </div>
    </section>
    <section v-else class="add_new_task_btn">
      <button id="new_task" v-on:click="show_new_task">+</button>
    </section>

    <section v-for="(tasks, month) in task_list" v-bind:id="month" class="task_wrapper">
      <h2 class="task_ym">{{month}}</h2>
      <ul>
        <li v-for="task in tasks" v-bind:id="'row_task_' + task.id" class="task_list">
          <div>{{task.date}} : {{task.title}}</div>
        </li>
      </ul>
    </section>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data: function () {
    return {
      new_task: {
        visible: false,
        start_at: '',
        title: '',
        detail: ''
      },
      task_list: {'2018/09' : [{"id":2,"date":2,"title":"222"},{"id":1,"date":2,"title":"111"}]}
    }
  },
  mounted: function() {
    this.fetch_tasks();
  },
  methods: {
    add_new_task: function() {
      // api succese or error
      axios.post('/tasks/add_task', {
        task: {
          title: this.$data.new_task.title,
          detail: this.$data.new_task.detail,
          start_at: this.$data.new_task.start_at
        }
      }).then((response) => {
        if (response.data.success) {
          this.$data.new_task.title = '';
          this.$data.new_task.detail = '';
          this.$data.new_task.visible = false;
          fetch_tasks();
        } else {
          alert("error!")
        }
      });
    },
    cancel_new_task: function() {
      this.$data.new_task.visible = false;
    },
    show_new_task: function(event) {
      this.$data.new_task.visible = true;
    },
    fetch_tasks: function() {
      var self = this;
      axios.get('/tasks/task_list').then((response) => {
        for (var key in response.data) {
          console.log(key + " >> " + JSON.stringify(response.data[key]));
          self.$data.task_list[key] = response.data[key]
        }
      })
    }
  }
}

</script>

<style>

</style>
